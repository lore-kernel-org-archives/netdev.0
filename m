From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] wan: kill 3 "unused" warnings
Date: Fri, 19 Sep 2003 11:32:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030919113252.67949bc8.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ncorbic@sangoma.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.0-test5.

--
~Randy


patch_name:	dscc_warnings.patch
patch_version:	2003-09-19.11:18:03
author:		Randy.Dunlap <rddunlap@osdl.org>
description:	kill 3 warnings (label, functions not used);
product:	Linux
product_versions: 2.6.0-test5
maintainer:	Nenad Corbic <ncorbic@sangoma.com>
diffstat:	=
 drivers/net/wan/dscc4.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)


diff -Naurp ./drivers/net/wan/dscc4.c~warnings ./drivers/net/wan/dscc4.c
--- ./drivers/net/wan/dscc4.c~warnings	2003-09-08 12:49:58.000000000 -0700
+++ ./drivers/net/wan/dscc4.c	2003-09-19 11:14:59.000000000 -0700
@@ -593,6 +593,7 @@ static inline int dscc4_xpr_ack(struct d
 	return (i >= 0 ) ? i : -EAGAIN;
 }
 
+#ifdef RESETS
 static void dscc4_rx_reset(struct dscc4_dev_priv *dpriv, struct net_device *dev)
 {
 	unsigned long flags;
@@ -626,6 +627,7 @@ static void dscc4_tx_reset(struct dscc4_
 	if (dscc4_do_action(dev, "Rdt") < 0)
 		printk(KERN_ERR "%s: Tx reset failed\n", dev->name);
 }
+#endif /* RESETS */
 
 /* TODO: (ab)use this function to refill a completely depleted RX ring. */
 static inline void dscc4_rx_skb(struct dscc4_dev_priv *dpriv,
@@ -1093,7 +1095,6 @@ done:
 
 err_disable_scc_events:
 	scc_writel(0xffffffff, dpriv, dev, IMR);
-err_free_ring:
 	scc_patchl(PowerUp | Vis, 0, dpriv, dev, CCR0);
 	dscc4_release_ring(dpriv);
 err_out:
