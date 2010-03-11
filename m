From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 07/37] drivers/serial: use .dev.of_node instead of .node in
	struct of_device
Date: Thu, 11 Mar 2010 11:04:26 -0700
Message-ID: <20100311180426.4824.5566.stgit__26171.7291469269$1268331610$gmane$org@angua>
References: <20100311174830.4824.19820.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:63703 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933563Ab0CKSE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:04:29 -0500
In-Reply-To: <20100311174830.4824.19820.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.node is being removed

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/serial/mpc52xx_uart.c |    8 ++++----
 drivers/serial/sunsu.c        |    6 +++---
 drivers/serial/sunzilog.c     |    8 ++++----
 drivers/serial/uartlite.c     |    6 +++---
 4 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/serial/mpc52xx_uart.c b/drivers/serial/mpc52xx_uart.c
index 3119fdd..cb07938 100644
--- a/drivers/serial/mpc52xx_uart.c
+++ b/drivers/serial/mpc52xx_uart.c
@@ -1328,14 +1328,14 @@ mpc52xx_uart_of_probe(struct of_device *op, const struct of_device_id *match)
 
 	/* Check validity & presence */
 	for (idx = 0; idx < MPC52xx_PSC_MAXNUM; idx++)
-		if (mpc52xx_uart_nodes[idx] == op->node)
+		if (mpc52xx_uart_nodes[idx] == op->dev.of_node)
 			break;
 	if (idx >= MPC52xx_PSC_MAXNUM)
 		return -EINVAL;
 	pr_debug("Found %s assigned to ttyPSC%x\n",
 		 mpc52xx_uart_nodes[idx]->full_name, idx);
 
-	uartclk = psc_ops->getuartclk(op->node);
+	uartclk = psc_ops->getuartclk(op->dev.of_node);
 	if (uartclk == 0) {
 		dev_dbg(&op->dev, "Could not find uart clock frequency!\n");
 		return -EINVAL;
@@ -1355,7 +1355,7 @@ mpc52xx_uart_of_probe(struct of_device *op, const struct of_device_id *match)
 	port->dev	= &op->dev;
 
 	/* Search for IRQ and mapbase */
-	ret = of_address_to_resource(op->node, 0, &res);
+	ret = of_address_to_resource(op->dev.of_node, 0, &res);
 	if (ret)
 		return ret;
 
@@ -1365,7 +1365,7 @@ mpc52xx_uart_of_probe(struct of_device *op, const struct of_device_id *match)
 		return -EINVAL;
 	}
 
-	psc_ops->get_irq(port, op->node);
+	psc_ops->get_irq(port, op->dev.of_node);
 	if (port->irq == NO_IRQ) {
 		dev_dbg(&op->dev, "Could not get irq\n");
 		return -EINVAL;
diff --git a/drivers/serial/sunsu.c b/drivers/serial/sunsu.c
index 170d3d6..2ab82ed 100644
--- a/drivers/serial/sunsu.c
+++ b/drivers/serial/sunsu.c
@@ -1199,7 +1199,7 @@ static int __devinit sunsu_kbd_ms_init(struct uart_sunsu_port *up)
 		return -ENODEV;
 
 	printk("%s: %s port at %llx, irq %u\n",
-	       to_of_device(up->port.dev)->node->full_name,
+	       to_of_device(up->port.dev)->dev.of_node->full_name,
 	       (up->su_type == SU_PORT_KBD) ? "Keyboard" : "Mouse",
 	       (unsigned long long) up->port.mapbase,
 	       up->port.irq);
@@ -1351,7 +1351,7 @@ static int __init sunsu_console_setup(struct console *co, char *options)
 	spin_lock_init(&port->lock);
 
 	/* Get firmware console settings.  */
-	sunserial_console_termios(co, to_of_device(port->dev)->node);
+	sunserial_console_termios(co, to_of_device(port->dev)->dev.of_node);
 
 	memset(&termios, 0, sizeof(struct ktermios));
 	termios.c_cflag = co->cflag;
@@ -1408,7 +1408,7 @@ static enum su_type __devinit su_get_type(struct device_node *dp)
 static int __devinit su_probe(struct of_device *op, const struct of_device_id *match)
 {
 	static int inst;
-	struct device_node *dp = op->node;
+	struct device_node *dp = op->dev.of_node;
 	struct uart_sunsu_port *up;
 	struct resource *rp;
 	enum su_type type;
diff --git a/drivers/serial/sunzilog.c b/drivers/serial/sunzilog.c
index 2c7a66a..20f9be8 100644
--- a/drivers/serial/sunzilog.c
+++ b/drivers/serial/sunzilog.c
@@ -1180,7 +1180,7 @@ static int __init sunzilog_console_setup(struct console *con, char *options)
 	       (sunzilog_reg.minor - 64) + con->index, con->index);
 
 	/* Get firmware console settings.  */
-	sunserial_console_termios(con, to_of_device(up->port.dev)->node);
+	sunserial_console_termios(con, to_of_device(up->port.dev)->dev.of_node);
 
 	/* Firmware console speed is limited to 150-->38400 baud so
 	 * this hackish cflag thing is OK.
@@ -1358,7 +1358,7 @@ static int __devinit zs_probe(struct of_device *op, const struct of_device_id *m
 	int keyboard_mouse = 0;
 	int err;
 
-	if (of_find_property(op->node, "keyboard", NULL))
+	if (of_find_property(op->dev.of_node, "keyboard", NULL))
 		keyboard_mouse = 1;
 
 	/* uarts must come before keyboards/mice */
@@ -1415,7 +1415,7 @@ static int __devinit zs_probe(struct of_device *op, const struct of_device_id *m
 	sunzilog_init_hw(&up[1]);
 
 	if (!keyboard_mouse) {
-		if (sunserial_console_match(SUNZILOG_CONSOLE(), op->node,
+		if (sunserial_console_match(SUNZILOG_CONSOLE(), op->dev.of_node,
 					    &sunzilog_reg, up[0].port.line,
 					    false))
 			up->flags |= SUNZILOG_FLAG_IS_CONS;
@@ -1425,7 +1425,7 @@ static int __devinit zs_probe(struct of_device *op, const struct of_device_id *m
 				   rp, sizeof(struct zilog_layout));
 			return err;
 		}
-		if (sunserial_console_match(SUNZILOG_CONSOLE(), op->node,
+		if (sunserial_console_match(SUNZILOG_CONSOLE(), op->dev.of_node,
 					    &sunzilog_reg, up[1].port.line,
 					    false))
 			up->flags |= SUNZILOG_FLAG_IS_CONS;
diff --git a/drivers/serial/uartlite.c b/drivers/serial/uartlite.c
index f0a6c61..8fc2583 100644
--- a/drivers/serial/uartlite.c
+++ b/drivers/serial/uartlite.c
@@ -591,15 +591,15 @@ ulite_of_probe(struct of_device *op, const struct of_device_id *match)
 
 	dev_dbg(&op->dev, "%s(%p, %p)\n", __func__, op, match);
 
-	rc = of_address_to_resource(op->node, 0, &res);
+	rc = of_address_to_resource(op->dev.of_node, 0, &res);
 	if (rc) {
 		dev_err(&op->dev, "invalid address\n");
 		return rc;
 	}
 
-	irq = irq_of_parse_and_map(op->node, 0);
+	irq = irq_of_parse_and_map(op->dev.of_node, 0);
 
-	id = of_get_property(op->node, "port-number", NULL);
+	id = of_get_property(op->dev.of_node, "port-number", NULL);
 
 	return ulite_assign(&op->dev, id ? *id : -1, res.start+3, irq);
 }

