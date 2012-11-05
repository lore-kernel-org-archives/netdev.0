From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH v3 2/6] net: calxedaxgmac: remove explicit rx dma buffer polling
Date: Mon,  5 Nov 2012 10:22:20 -0600
Message-ID: <1352132544-15809-3-git-send-email-robherring2@gmail.com>
References: <1352132544-15809-1-git-send-email-robherring2@gmail.com>
Cc: eric.dumazet@gmail.com, Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:49379 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505Ab2KEQWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 11:22:41 -0500
Received: by mail-oa0-f46.google.com with SMTP id h16so5924901oag.19
        for <netdev@vger.kernel.org>; Mon, 05 Nov 2012 08:22:41 -0800 (PST)
In-Reply-To: <1352132544-15809-1-git-send-email-robherring2@gmail.com>
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
