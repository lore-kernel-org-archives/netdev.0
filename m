From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 19/37] drivers/serial: use .dev.of_node instead of .node in
	struct of_device
Date: Thu, 11 Mar 2010 11:05:33 -0700
Message-ID: <20100311180532.4824.64755.stgit__28833.0692834736$1268331239$gmane$org@angua>
References: <20100311174830.4824.19820.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f194.google.com ([209.85.222.194]:34774 "EHLO
	mail-pz0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933693Ab0CKSFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:05:44 -0500
In-Reply-To: <20100311174830.4824.19820.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.node is being removed

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/serial/apbuart.c    |    2 +-
 drivers/serial/nwpserial.c  |    2 +-
 drivers/serial/of_serial.c  |    4 ++--
 drivers/serial/pmac_zilog.c |    2 +-
 drivers/serial/sunhv.c      |    2 +-
 drivers/serial/sunsab.c     |    6 +++---
 6 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/serial/apbuart.c b/drivers/serial/apbuart.c
index fe91319..52015d7 100644
--- a/drivers/serial/apbuart.c
+++ b/drivers/serial/apbuart.c
@@ -559,7 +559,7 @@ static int __devinit apbuart_probe(struct of_device *op,
 
 	i = 0;
 	for (i = 0; i < grlib_apbuart_port_nr; i++) {
-		if (op->node == grlib_apbuart_nodes[i])
+		if (op->dev.of_node == grlib_apbuart_nodes[i])
 			break;
 	}
 
diff --git a/drivers/serial/nwpserial.c b/drivers/serial/nwpserial.c
index e1ab8ec..3c02fa9 100644
--- a/drivers/serial/nwpserial.c
+++ b/drivers/serial/nwpserial.c
@@ -344,7 +344,7 @@ int nwpserial_register_port(struct uart_port *port)
 
 	mutex_lock(&nwpserial_mutex);
 
-	dn = to_of_device(port->dev)->node;
+	dn = to_of_device(port->dev)->dev.of_node;
 	if (dn == NULL)
 		goto out;
 
diff --git a/drivers/serial/of_serial.c b/drivers/serial/of_serial.c
index cdf172e..18bf39b 100644
--- a/drivers/serial/of_serial.c
+++ b/drivers/serial/of_serial.c
@@ -30,7 +30,7 @@ static int __devinit of_platform_serial_setup(struct of_device *ofdev,
 					int type, struct uart_port *port)
 {
 	struct resource resource;
-	struct device_node *np = ofdev->node;
+	struct device_node *np = ofdev->dev.of_node;
 	const unsigned int *clk, *spd;
 	const u32 *prop;
 	int ret, prop_size;
@@ -87,7 +87,7 @@ static int __devinit of_platform_serial_probe(struct of_device *ofdev,
 	int port_type;
 	int ret;
 
-	if (of_find_property(ofdev->node, "used-by-rtas", NULL))
+	if (of_find_property(ofdev->dev.of_node, "used-by-rtas", NULL))
 		return -EBUSY;
 
 	info = kmalloc(sizeof(*info), GFP_KERNEL);
diff --git a/drivers/serial/pmac_zilog.c b/drivers/serial/pmac_zilog.c
index f020de1..8abbbb3 100644
--- a/drivers/serial/pmac_zilog.c
+++ b/drivers/serial/pmac_zilog.c
@@ -1610,7 +1610,7 @@ static int pmz_attach(struct macio_dev *mdev, const struct of_device_id *match)
 	/* Iterate the pmz_ports array to find a matching entry
 	 */
 	for (i = 0; i < MAX_ZS_PORTS; i++)
-		if (pmz_ports[i].node == mdev->ofdev.node) {
+		if (pmz_ports[i].node == mdev->ofdev.dev.of_node) {
 			struct uart_pmac_port *uap = &pmz_ports[i];
 
 			uap->dev = mdev;
diff --git a/drivers/serial/sunhv.c b/drivers/serial/sunhv.c
index d14cca7..d1eedf1 100644
--- a/drivers/serial/sunhv.c
+++ b/drivers/serial/sunhv.c
@@ -565,7 +565,7 @@ static int __devinit hv_probe(struct of_device *op, const struct of_device_id *m
 	if (err)
 		goto out_free_con_read_page;
 
-	sunserial_console_match(&sunhv_console, op->node,
+	sunserial_console_match(&sunhv_console, op->dev.of_node,
 				&sunhv_reg, port->line, false);
 
 	err = uart_add_one_port(&sunhv_reg, port);
diff --git a/drivers/serial/sunsab.c b/drivers/serial/sunsab.c
index d514e28..2b8b2c2 100644
--- a/drivers/serial/sunsab.c
+++ b/drivers/serial/sunsab.c
@@ -883,7 +883,7 @@ static int sunsab_console_setup(struct console *con, char *options)
 	printk("Console: ttyS%d (SAB82532)\n",
 	       (sunsab_reg.minor - 64) + con->index);
 
-	sunserial_console_termios(con, to_of_device(up->port.dev)->node);
+	sunserial_console_termios(con, to_of_device(up->port.dev)->dev.of_node);
 
 	switch (con->cflag & CBAUD) {
 	case B150: baud = 150; break;
@@ -1026,11 +1026,11 @@ static int __devinit sab_probe(struct of_device *op, const struct of_device_id *
 	if (err)
 		goto out1;
 
-	sunserial_console_match(SUNSAB_CONSOLE(), op->node,
+	sunserial_console_match(SUNSAB_CONSOLE(), op->dev.of_node,
 				&sunsab_reg, up[0].port.line,
 				false);
 
-	sunserial_console_match(SUNSAB_CONSOLE(), op->node,
+	sunserial_console_match(SUNSAB_CONSOLE(), op->dev.of_node,
 				&sunsab_reg, up[1].port.line,
 				false);
 

