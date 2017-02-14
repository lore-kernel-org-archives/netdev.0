From: Manuel Lauss <manuel.lauss@gmail.com>
Subject: [PATCH 1/2] net: irda: au1k_ir: remove unused timer
Date: Tue, 14 Feb 2017 13:08:03 +0100
Message-ID: <20170214120804.248871-1-manuel.lauss@gmail.com>
Cc: Manuel Lauss <manuel.lauss@gmail.com>
To: netdev@vger.kernel.org, Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33441 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751853AbdBNMII (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 07:08:08 -0500
Received: by mail-wr0-f193.google.com with SMTP id i10so27405657wrb.0
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2017 04:08:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

remove the unused timer.  I suppose it was intended as a timeout
detector, but never properly implemented.

Signed-off-by: Manuel Lauss <manuel.lauss@gmail.com>
---
 drivers/net/irda/au1k_ir.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index 44e4f386a5dc..bc2a63f5ca8c 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -169,8 +169,6 @@ struct au1k_private {
 	u32 speed;
 	u32 newspeed;
 
-	struct timer_list timer;
-
 	struct resource *ioarea;
 	struct au1k_irda_platform_data *platdata;
 	struct clk *irda_clk;
@@ -178,8 +176,6 @@ struct au1k_private {
 
 static int qos_mtt_bits = 0x07;  /* 1 ms or more */
 
-#define RUN_AT(x) (jiffies + (x))
-
 static void au1k_irda_plat_set_phy_mode(struct au1k_private *p, int mode)
 {
 	if (p->platdata && p->platdata->set_phy_mode)
@@ -620,8 +616,6 @@ static int au1k_irda_start(struct net_device *dev)
 	/* power up */
 	au1k_irda_plat_set_phy_mode(aup, AU1000_IRDA_PHY_MODE_SIR);
 
-	aup->timer.expires = RUN_AT((3 * HZ));
-	aup->timer.data = (unsigned long)dev;
 	return 0;
 }
 
@@ -642,7 +636,6 @@ static int au1k_irda_stop(struct net_device *dev)
 	}
 
 	netif_stop_queue(dev);
-	del_timer(&aup->timer);
 
 	/* disable the interrupt */
 	free_irq(aup->irq_tx, dev);
-- 
2.11.1
