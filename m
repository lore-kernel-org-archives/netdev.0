From: bora.sahin@ttnet.net.tr
Subject: [PATCH 5/12] smc911x: SMC_SET_IRQ_CFG is arch specific
Date: Wed, 13 Sep 2006 20:54:12 +0300
Message-ID: <200609132054.12804.bora.sahin@ttnet.net.tr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ttnet.net.tr ([212.175.13.129]:56954 "EHLO
	fep03.ttnet.net.tr") by vger.kernel.org with ESMTP id S1751054AbWIMSex
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 14:34:53 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


SMC_SET_IRQ_CFG macro is PXA specific...

Signed-off-by: Bora Sahin <bora.sahin@ttnet.net.tr>

Index: linux-2.6.18-rc4/drivers/net/smc911x.c
===================================================================
--- linux-2.6.18-rc4.orig/drivers/net/smc911x.c	2006-08-06 21:20:11.000000000 +0300
+++ linux-2.6.18-rc4/drivers/net/smc911x.c	2006-09-04 13:54:26.621458832 +0300
@@ -306,12 +307,14 @@
 	/* Set to LED outputs */
 	SMC_SET_GPIO_CFG(0x70070000);
 
+#ifdef CONFIG_ARCH_PXA
 	/*
 	 * Deassert IRQ for 1*10us for edge type interrupts
 	 * and drive IRQ pin push-pull
 	 */
-	SMC_SET_IRQ_CFG( (1 << 24) | INT_CFG_IRQ_EN_ | INT_CFG_IRQ_TYPE_ );
-
+	SMC_SET_IRQ_CFG((1 << 24) | INT_CFG_IRQ_EN_ | INT_CFG_IRQ_TYPE_);
+#endif
+	
 	/* clear anything saved */
 	if (lp->pending_tx_skb != NULL) {
 		dev_kfree_skb (lp->pending_tx_skb);

