
-- SUNRISE SUPERMARKET - ASSIGNMENT ONE

-- 1. CREATE TABLES
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50)
);


CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price NUMERIC(10,2)
);


CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date DATE
);


CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    product_id INT REFERENCES products(product_id),
    quantity INT
);

-- 2. INSERT CUSTOMERS

INSERT INTO customers
(customer_id, customer_name, email, city)
VALUES
(1, 'Alice Uwase', 'alice@example.com', 'Kigali'),
(2, 'Brian Niyonzima', 'brian@example.com', 'Musanze'),
(3, 'Clara Mukamana', 'clara@example.com', 'Huye'),
(4, 'David Habimana', 'david@example.com', 'Rubavu'),
(5, 'Eva Ingabire', 'eva@example.com', 'Kigali');

-- 3. INSERT PRODUCTS

INSERT INTO products
(product_id, product_name, category, price)
VALUES
(101, 'Rice 5kg', 'Groceries', 7500),
(102, 'Cooking Oil 1L', 'Groceries', 4500),
(103, 'Sugar 1kg', 'Groceries', 1800),
(104, 'Milk 1L', 'Dairy', 1500),
(105, 'Cheese 500g', 'Dairy', 6500),
(106, 'Laundry Soap', 'Household', 2200),
(107, 'Dishwashing Liquid', 'Household', 3000),
(108, 'Biscuits Pack', 'Snacks', 2500);

-- 4. INSERT ORDERS

INSERT INTO orders
(order_id, customer_id, order_date)
VALUES
(1001, 1, '2026-01-05'),
(1002, 2, '2026-01-08'),
(1003, 1, '2026-01-17'),
(1004, 3, '2026-01-22'),
(1005, 4, '2026-02-02'),
(1006, 2, '2026-02-09'),
(1007, 1, '2026-02-14'),
(1008, 3, '2026-02-20'),
(1009, 4, '2026-02-28'),
(1010, 2, '2026-03-04'),
(1011, 1, '2026-03-10'),
(1012, 3, '2026-03-15'),
(1013, 4, '2026-03-19'),
(1014, 2, '2026-03-23'),
(1015, 1, '2026-03-28');

-- 5. INSERT ORDER ITEMS

INSERT INTO order_items
(order_item_id, order_id, product_id, quantity)
VALUES
(1, 1001, 101, 2),
(2, 1001, 104, 3),

(3, 1002, 102, 2),
(4, 1002, 108, 4),

(5, 1003, 103, 5),
(6, 1003, 106, 2),

(7, 1004, 105, 1),
(8, 1004, 108, 3),

(9, 1005, 101, 1),
(10, 1005, 107, 2),

(11, 1006, 104, 6),
(12, 1006, 106, 3),

(13, 1007, 101, 3),
(14, 1007, 102, 2),

(15, 1008, 103, 4),
(16, 1008, 105, 2),

(17, 1009, 106, 5),
(18, 1009, 107, 1),

(19, 1010, 108, 8),
(20, 1010, 104, 2),

(21, 1011, 102, 4),
(22, 1011, 105, 1),

(23, 1012, 101, 2),
(24, 1012, 107, 3),

(25, 1013, 103, 6),
(26, 1013, 108, 5),

(27, 1014, 106, 4),
(28, 1014, 102, 3),

(29, 1015, 101, 1),
(30, 1015, 105, 2);

-- QUESTION 1
-- List every order with customer's name, city and order date
-- INNER JOIN: orders + customers

SELECT
    o.order_id,
    c.customer_name,
    c.city,
    o.order_date
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id
ORDER BY o.order_date;

-- QUESTION 2
-- List every order item with product name, category,
-- price and quantity ordered
-- JOIN: order_items + products

SELECT
    oi.order_item_id,
    oi.order_id,
    p.product_name,
    p.category,
    p.price,
    oi.quantity
FROM order_items oi
INNER JOIN products p
    ON oi.product_id = p.product_id
ORDER BY oi.order_id;

-- QUESTION 3
-- List ALL customers and their orders,
-- including customers who have never placed an order
-- LEFT JOIN

SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    o.order_id,
    o.order_date
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
ORDER BY c.customer_id;

-- QUESTION 4
-- Calculate each customer's total amount spent
-- and return customers who spent ABOVE the average.
-- CTE

WITH customer_totals AS (

    SELECT
        c.customer_id,
        c.customer_name,
        COALESCE(SUM(oi.quantity * p.price), 0) AS total_spent

    FROM customers c

    LEFT JOIN orders o
        ON c.customer_id = o.customer_id

    LEFT JOIN order_items oi
        ON o.order_id = oi.order_id

    LEFT JOIN products p
        ON oi.product_id = p.product_id

    GROUP BY
        c.customer_id,
        c.customer_name
)

SELECT
    customer_id,
    customer_name,
    total_spent

FROM customer_totals

WHERE total_spent >
      (SELECT AVG(total_spent)
       FROM customer_totals)

ORDER BY total_spent DESC;
-- QUESTION 5
-- Rank customers by total amount spent,
-- highest first.
-- WINDOW FUNCTION: RANK()

WITH customer_totals AS (

    SELECT
        c.customer_id,
        c.customer_name,
        COALESCE(SUM(oi.quantity * p.price), 0) AS total_spent

    FROM customers c

    LEFT JOIN orders o
        ON c.customer_id = o.customer_id

    LEFT JOIN order_items oi
        ON o.order_id = oi.order_id

    LEFT JOIN products p
        ON oi.product_id = p.product_id

    GROUP BY
        c.customer_id,
        c.customer_name
)

SELECT
    customer_id,
    customer_name,
    total_spent,

    RANK() OVER (
        ORDER BY total_spent DESC
    ) AS spending_rank

FROM customer_totals

ORDER BY spending_rank;
-- QUESTION 6
-- Number each customer's orders in the order they were placed.
-- WINDOW FUNCTION: ROW_NUMBER()

SELECT
    o.order_id,
    c.customer_name,
    o.order_date,

    ROW_NUMBER() OVER (
        PARTITION BY o.customer_id
        ORDER BY o.order_date, o.order_id
    ) AS customer_order_number

FROM orders o

INNER JOIN customers c
    ON o.customer_id = c.customer_id

ORDER BY
    c.customer_name,
    customer_order_number;
-- QUESTION 7
-- Show a running total of revenue over time.
-- WINDOW FUNCTION: SUM() OVER()

WITH daily_revenue AS (

    SELECT
        o.order_date,
        SUM(oi.quantity * p.price) AS daily_revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    JOIN products p
        ON oi.product_id = p.product_id

    GROUP BY o.order_date
)

SELECT
    order_date,
    daily_revenue,

    SUM(daily_revenue) OVER (
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS running_revenue

FROM daily_revenue

ORDER BY order_date;
-- QUESTION 8
-- For customers with more than one order,
-- show the number of days between current and previous order.
-- WINDOW FUNCTION: LAG()

WITH customer_orders AS (

    SELECT
        o.customer_id,
        c.customer_name,
        o.order_id,
        o.order_date,

        LAG(o.order_date) OVER (
            PARTITION BY o.customer_id
            ORDER BY o.order_date, o.order_id
        ) AS previous_order_date,

        COUNT(*) OVER (
            PARTITION BY o.customer_id
        ) AS order_count

    FROM orders o

    JOIN customers c
        ON o.customer_id = c.customer_id
)

SELECT
    customer_id,
    customer_name,
    order_id,
    order_date,
    previous_order_date,

    order_date - previous_order_date
        AS days_since_previous_order

FROM customer_orders

WHERE order_count > 1
AND previous_order_date IS NOT NULL

ORDER BY
    customer_id,
    order_date;
