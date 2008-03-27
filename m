From: Sebastian Siewior <bigeasy@linutronix.de>
Subject: [PATCH / RFC 1/2] fec: kill warnings
Date: Thu, 27 Mar 2008 15:00:42 +0100
Message-ID: <20080327140119.658973905@linutronix.de>
References: <20080327140041.072611004@linutronix.de>
Cc: netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>,
	Greg Ungerer <gerg@uclinux.org>
To: uclinux-dev@uclinux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:42825 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756799AbYC0OLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 10:11:10 -0400
Content-Disposition: inline; filename=m68knommu-remove_unused_in_fec.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

linux-2.6/drivers/net/fec.c: In function 'fec_enet_module_init':
linux-2.6/drivers/net/fec.c:2627: warning: unused variable 'j'
linux-2.6/drivers/net/fec.c: At top level:
linux-2.6/drivers/net/fec.c:2136: warning: 'mii_link_interrupt' defined but not used

Signed-off-by: Sebastian Siewior <bigeasy@linutronix.de>
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -67,6 +67,11 @@
 #define	FEC_MAX_PORTS	1
 #endif
 
+#if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x) || \
+	defined(CONFIG_M520x) || defined(CONFIG_M532x)
+#define DONT_NEED_mii_link_interrupt
+#endif
+
 /*
  * Define the fixed address of the FEC hardware.
  */
@@ -1222,7 +1227,7 @@ static phy_info_t const * const phy_info
 };
 
 /* ------------------------------------------------------------------------- */
-#if !defined(CONFIG_M532x)
+#ifndef DONT_NEED_mii_link_interrupt
 #ifdef CONFIG_RPXCLASSIC
 static void
 mii_link_interrupt(void *dev_id);
@@ -2126,6 +2131,7 @@ mii_discover_phy(uint mii_reg, struct ne
 
 /* This interrupt occurs when the PHY detects a link change.
 */
+#ifndef DONT_NEED_mii_link_interrupt
 #ifdef CONFIG_RPXCLASSIC
 static void
 mii_link_interrupt(void *dev_id)
@@ -2148,6 +2154,7 @@ mii_link_interrupt(int irq, void * dev_i
 
 	return IRQ_HANDLED;
 }
+#endif
 
 static int
 fec_enet_open(struct net_device *dev)
@@ -2624,7 +2631,7 @@ fec_stop(struct net_device *dev)
 static int __init fec_enet_module_init(void)
 {
 	struct net_device *dev;
-	int i, j, err;
+	int i, err;
 	DECLARE_MAC_BUF(mac);
 
 	printk("FEC ENET Version 0.2\n");

-- 

