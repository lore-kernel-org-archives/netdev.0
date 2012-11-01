From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH v2 RESEND 1/6] net: calxedaxgmac: enable operate on 2nd frame mode
Date: Thu,  1 Nov 2012 05:40:59 -0500
Message-ID: <1351766464-27354-2-git-send-email-robherring2@gmail.com>
References: <1351766464-27354-1-git-send-email-robherring2@gmail.com>
Cc: eric.dumazet@gmail.com, Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:59212 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755802Ab2KAKlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 06:41:21 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1000967bkc.19
        for <netdev@vger.kernel.org>; Thu, 01 Nov 2012 03:41:20 -0700 (PDT)
In-Reply-To: <1351766464-27354-1-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <rob.herring@calxeda.com>

Enable the tx dma to start reading the next frame while sending the current
frame.

Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 16814b3..7f5fd17 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -191,6 +191,7 @@
 #define DMA_CONTROL_ST		0x00002000	/* Start/Stop Transmission */
 #define DMA_CONTROL_SR		0x00000002	/* Start/Stop Receive */
 #define DMA_CONTROL_DFF		0x01000000	/* Disable flush of rx frames */
+#define DMA_CONTROL_OSF		0x00000004	/* Operate on 2nd tx frame */
 
 /* DMA Normal interrupt */
 #define DMA_INTR_ENA_NIE	0x00010000	/* Normal Summary */
@@ -965,8 +966,7 @@ static int xgmac_hw_init(struct net_device *dev)
 		ctrl |= XGMAC_CONTROL_IPC;
 	writel(ctrl, ioaddr + XGMAC_CONTROL);
 
-	value = DMA_CONTROL_DFF;
-	writel(value, ioaddr + XGMAC_DMA_CONTROL);
+	writel(DMA_CONTROL_DFF | DMA_CONTROL_OSF, ioaddr + XGMAC_DMA_CONTROL);
 
 	/* Set the HW DMA mode and the COE */
 	writel(XGMAC_OMR_TSF | XGMAC_OMR_RFD | XGMAC_OMR_RFA |
-- 
1.7.10.4
