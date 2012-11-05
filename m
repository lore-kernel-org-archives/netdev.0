From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH v3 4/6] net: calxedaxgmac: drop some unnecessary register writes
Date: Mon,  5 Nov 2012 10:22:22 -0600
Message-ID: <1352132544-15809-5-git-send-email-robherring2@gmail.com>
References: <1352132544-15809-1-git-send-email-robherring2@gmail.com>
Cc: eric.dumazet@gmail.com, Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:33164 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752901Ab2KEQWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 11:22:46 -0500
Received: by mail-ob0-f174.google.com with SMTP id uo13so5859114obb.19
        for <netdev@vger.kernel.org>; Mon, 05 Nov 2012 08:22:46 -0800 (PST)
In-Reply-To: <1352132544-15809-1-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <rob.herring@calxeda.com>

The interrupts have already been cleared, so we don't need to clear them
again. Also, we could miss interrupts if they are cleared, but we don't
process the packet.

Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 84cd40e..8263219 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -846,9 +846,6 @@ static void xgmac_free_dma_desc_rings(struct xgmac_priv *priv)
 static void xgmac_tx_complete(struct xgmac_priv *priv)
 {
 	int i;
-	void __iomem *ioaddr = priv->base;
-
-	writel(DMA_STATUS_TU | DMA_STATUS_NIS, ioaddr + XGMAC_DMA_STATUS);
 
 	while (dma_ring_cnt(priv->tx_head, priv->tx_tail, DMA_TX_RING_SZ)) {
 		unsigned int entry = priv->tx_tail;
@@ -1139,9 +1136,6 @@ static int xgmac_rx(struct xgmac_priv *priv, int limit)
 		struct sk_buff *skb;
 		int frame_len;
 
-		writel(DMA_STATUS_RI | DMA_STATUS_NIS,
-		       priv->base + XGMAC_DMA_STATUS);
-
 		entry = priv->rx_tail;
 		p = priv->dma_rx + entry;
 		if (desc_get_owner(p))
-- 
1.7.10.4
