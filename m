From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH v2 RESEND 2/6] net: calxedaxgmac: remove explicit rx dma buffer polling
Date: Thu,  1 Nov 2012 05:41:00 -0500
Message-ID: <1351766464-27354-3-git-send-email-robherring2@gmail.com>
References: <1351766464-27354-1-git-send-email-robherring2@gmail.com>
Cc: eric.dumazet@gmail.com, Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:64228 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756122Ab2KAKlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 06:41:22 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1000955bkc.19
        for <netdev@vger.kernel.org>; Thu, 01 Nov 2012 03:41:22 -0700 (PDT)
In-Reply-To: <1351766464-27354-1-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <rob.herring@calxeda.com>

New received frames will trigger the rx DMA to poll the DMA descriptors,
so there is no need to tell the h/w to poll. We also want to enable
dropping frames from the fifo when there is no buffer.

Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 7f5fd17..728fcef 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -966,7 +966,7 @@ static int xgmac_hw_init(struct net_device *dev)
 		ctrl |= XGMAC_CONTROL_IPC;
 	writel(ctrl, ioaddr + XGMAC_CONTROL);
 
-	writel(DMA_CONTROL_DFF | DMA_CONTROL_OSF, ioaddr + XGMAC_DMA_CONTROL);
+	writel(DMA_CONTROL_OSF, ioaddr + XGMAC_DMA_CONTROL);
 
 	/* Set the HW DMA mode and the COE */
 	writel(XGMAC_OMR_TSF | XGMAC_OMR_RFD | XGMAC_OMR_RFA |
@@ -1180,8 +1180,6 @@ static int xgmac_rx(struct xgmac_priv *priv, int limit)
 
 	xgmac_rx_refill(priv);
 
-	writel(1, priv->base + XGMAC_DMA_RX_POLL);
-
 	return count;
 }
 
-- 
1.7.10.4
