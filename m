From: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>
Subject: [PATCH 2.6.10 5/5] eepro: fix auto-detection option
Date: Fri, 7 Jan 2005 09:53:17 -0200
Message-ID: <20050107115317.GW27328@cathedrallabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

eepro: fix auto-detection option

Signed-off-by: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>

--- 2.6-dual/drivers/net/eepro.c.orig	2004-10-05 22:27:55.000000000 -0300
+++ 2.6-dual/drivers/net/eepro.c	2004-10-05 21:44:23.000000000 -0300
@@ -1779,7 +1779,9 @@ static struct ethtool_ops eepro_ethtool_
 #define MAX_EEPRO 8
 static struct net_device *dev_eepro[MAX_EEPRO];
 
-static int io[MAX_EEPRO];
+static int io[MAX_EEPRO] = {
+  [0 ... MAX_EEPRO-1] = -1
+};
 static int irq[MAX_EEPRO];
 static int mem[MAX_EEPRO] = {	/* Size of the rx buffer in KB */
   [0 ... MAX_EEPRO-1] = RCV_DEFAULT_RAM/1024
@@ -1808,19 +1810,21 @@ init_module(void)
 {
 	struct net_device *dev;
 	int i;
-	if (io[0] == 0 && autodetect == 0) {
+	if (io[0] == -1 && autodetect == 0) {
 		printk(KERN_WARNING "eepro_init_module: Probe is very dangerous in ISA boards!\n");
 		printk(KERN_WARNING "eepro_init_module: Please add \"autodetect=1\" to force probe\n");
 		return -ENODEV;
 	}
 	else if (autodetect) {
 		/* if autodetect is set then we must force detection */
-		io[0] = 0;
+		for (i = 0; i < MAX_EEPRO; i++) {
+			io[i] = 0;
+		}
 
 		printk(KERN_INFO "eepro_init_module: Auto-detecting boards (May God protect us...)\n");
 	}
 
-	for (i = 0; i < MAX_EEPRO; i++) {
+	for (i = 0; io[i] != -1 && i < MAX_EEPRO; i++) {
 		dev = alloc_etherdev(sizeof(struct eepro_local));
 		if (!dev)
 			break;
