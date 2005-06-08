From: Pavel Machek <pavel@ucw.cz>
Subject: [-mm] ipw2100 cleanups: no X___ prefixes
Date: Wed, 8 Jun 2005 15:20:19 +0200
Message-ID: <20050608132019.GA2620@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev list <netdev@oss.sgi.com>,
        "James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
        Andrew Morton <akpm@zip.com.au>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

ipw2100 uses strange X__ prefixes even for symbols already prefixed
by ipw2100. Fixed.

Signed-off-by: Pavel Machek <pavel@suse.cz>

--- /data/l/clean-mm/drivers/net/wireless/ipw2100.c	2005-06-08 12:11:29.000000000 +0200
+++ linux-mm/drivers/net/wireless/ipw2100.c	2005-06-08 15:09:26.000000000 +0200
@@ -106,7 +106,7 @@
 
   tx_pend_list : Holds used Tx buffers waiting to go into the TBD ring
     TAIL modified ipw2100_tx()
-    HEAD modified by X__ipw2100_tx_send_data()
+    HEAD modified by ipw2100_tx_send_data()
 
   msg_free_list : Holds pre-allocated Msg (Command) buffers
     TAIL modified in __ipw2100_tx_process()
@@ -114,7 +114,7 @@
 
   msg_pend_list : Holds used Msg buffers waiting to go into the TBD ring
     TAIL modified in ipw2100_hw_send_command()
-    HEAD modified in X__ipw2100_tx_send_commands()
+    HEAD modified in ipw2100_tx_send_commands()
 
   The flow of data on the TX side is as follows:
 
@@ -287,8 +279,8 @@
 
 
 /* Pre-decl until we get the code solid and then we can clean it up */
-static void X__ipw2100_tx_send_commands(struct ipw2100_priv *priv);
-static void X__ipw2100_tx_send_data(struct ipw2100_priv *priv);
+static void ipw2100_tx_send_commands(struct ipw2100_priv *priv);
+static void ipw2100_tx_send_data(struct ipw2100_priv *priv);
 static int ipw2100_adapter_setup(struct ipw2100_priv *priv);
 
 static void ipw2100_queues_initialize(struct ipw2100_priv *priv);
@@ -2841,14 +2736,14 @@
 	while (__ipw2100_tx_process(priv) && i < 200) i++;
 
 	if (i == 200) {
-		IPW_DEBUG_WARNING(
+		printk(KERN_WARNING DRV_NAME ": "
 		       "%s: Driver is running slow (%d iters).\n",
 		       priv->net_dev->name, i);
 	}
 }
 
 
-static void X__ipw2100_tx_send_commands(struct ipw2100_priv *priv)
+static void ipw2100_tx_send_commands(struct ipw2100_priv *priv)
 {
 	struct list_head *element;
 	struct ipw2100_tx_packet *packet;
@@ -2916,10 +2811,10 @@
 
 
 /*
- * X__ipw2100_tx_send_data
+ * ipw2100_tx_send_data
  *
  */
-static void X__ipw2100_tx_send_data(struct ipw2100_priv *priv)
+static void ipw2100_tx_send_data(struct ipw2100_priv *priv)
 {
 	struct list_head *element;
 	struct ipw2100_tx_packet *packet;
@@ -3134,8 +3029,8 @@
 			       IPW2100_INTA_TX_TRANSFER);
 
 		__ipw2100_tx_complete(priv);
-		X__ipw2100_tx_send_commands(priv);
-		X__ipw2100_tx_send_data(priv);
+		ipw2100_tx_send_commands(priv);
+		ipw2100_tx_send_data(priv);
 	}
 
 	if (inta & IPW2100_INTA_TX_COMPLETE) {
@@ -3286,7 +3179,7 @@
 	list_add_tail(element, &priv->tx_pend_list);
 	INC_STAT(&priv->tx_pend_stat);
 
-	X__ipw2100_tx_send_data(priv);
+	ipw2100_tx_send_data(priv);
 
 	spin_unlock_irqrestore(&priv->low_lock, flags);
 	return 0;
