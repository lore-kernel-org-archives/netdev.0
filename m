From: Richard Knutsson <ricknu-0@student.ltu.se>
Subject: [PATCH] 8139cp: Convert to generic boolean
Date: Sat, 19 May 2007 22:26:40 +0200 (MEST)
Message-ID: <20070519202916.26748.29121.sendpatchset@thinktank.campus.ltu.se>
Cc: netdev@vger.kernel.org, Richard Knutsson <ricknu-0@student.ltu.se>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gepetto.dc.ltu.se ([130.240.42.40]:42712 "EHLO
	gepetto.dc.ltu.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756860AbXESU0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2007 16:26:45 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Richard Knutsson <ricknu-0@student.ltu.se>
---
Compile-tested with all(yes|mod|no)config on x86(|_64) & sparc(|64)
Diffed against Linus' git-tree.


diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index e8c9f27..635d0ab 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -107,11 +107,6 @@ MODULE_PARM_DESC (multicast_filter_limit, "8139cp: maximum number of filtered mu
 
 #define PFX			DRV_NAME ": "
 
-#ifndef TRUE
-#define FALSE 0
-#define TRUE (!FALSE)
-#endif
-
 #define CP_DEF_MSG_ENABLE	(NETIF_MSG_DRV		| \
 				 NETIF_MSG_PROBE 	| \
 				 NETIF_MSG_LINK)
@@ -669,7 +664,7 @@ static irqreturn_t cp_interrupt (int irq, void *dev_instance)
 	if (status & (TxOK | TxErr | TxEmpty | SWInt))
 		cp_tx(cp);
 	if (status & LinkChg)
-		mii_check_media(&cp->mii_if, netif_msg_link(cp), FALSE);
+		mii_check_media(&cp->mii_if, netif_msg_link(cp), false);
 
 	spin_unlock(&cp->lock);
 
@@ -1196,7 +1191,7 @@ static int cp_open (struct net_device *dev)
 		goto err_out_hw;
 
 	netif_carrier_off(dev);
-	mii_check_media(&cp->mii_if, netif_msg_link(cp), TRUE);
+	mii_check_media(&cp->mii_if, netif_msg_link(cp), true);
 	netif_start_queue(dev);
 
 	return 0;
@@ -2059,7 +2054,7 @@ static int cp_resume (struct pci_dev *pdev)
 
 	spin_lock_irqsave (&cp->lock, flags);
 
-	mii_check_media(&cp->mii_if, netif_msg_link(cp), FALSE);
+	mii_check_media(&cp->mii_if, netif_msg_link(cp), false);
 
 	spin_unlock_irqrestore (&cp->lock, flags);
 
