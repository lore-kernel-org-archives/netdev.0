From: bora.sahin@ttnet.net.tr
Subject: [PATCH 10/12] smc911x: phy_configure releases spinlocks before grabing
Date: Wed, 13 Sep 2006 21:32:51 +0300
Message-ID: <200609132132.51674.bora.sahin@ttnet.net.tr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ttnet.net.tr ([212.175.13.129]:10365 "EHLO
	fep03.ttnet.net.tr") by vger.kernel.org with ESMTP id S1751061AbWIMSfR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 14:35:17 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


phy_configure releases spinlocks before grabing...

Signed-off-by: Bora Sahin <bora.sahin@ttnet.net.tr>

Index: linux-2.6.18-rc4/drivers/net/smc911x.c
===================================================================
--- linux-2.6.18-rc4.orig/drivers/net/smc911x.c	2006-08-06 21:20:11.000000000 +0300
+++ linux-2.6.18-rc4/drivers/net/smc911x.c	2006-09-04 13:54:26.621458832 +0300
@@ -961,17 +958,17 @@
 	int status;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s()\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
 
 	/*
 	 * We should not be called if phy_type is zero.
 	 */
 	if (lp->phy_type == 0)
-		 goto smc911x_phy_configure_exit;
+		 goto smc911x_phy_configure_early_exit;
 
 	if (smc911x_phy_reset(dev, phyaddr)) {
 		printk("%s: PHY reset timed out\n", dev->name);
-		goto smc911x_phy_configure_exit;
+		goto smc911x_phy_configure_early_exit;
 	}
 	spin_lock_irqsave(&lp->lock, flags);
 
@@ -1040,6 +1037,7 @@
 
 smc911x_phy_configure_exit:
 	spin_unlock_irqrestore(&lp->lock, flags);
+smc911x_phy_configure_early_exit:	
 	lp->work_pending = 0;
 }
 
