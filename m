From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 12/14] forcedeth: convert to SKB paged frag API.
Date: Tue, 30 Aug 2011 10:18:28 +0100
Message-ID: <1314695910-22344-12-git-send-email-ian.campbell@citrix.com>
References: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:22544 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751311Ab1H3JSu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 05:18:50 -0400
In-Reply-To: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/nvidia/forcedeth.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 98bb64b..4e39b8c 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -2146,8 +2146,11 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			prev_tx = put_tx;
 			prev_tx_ctx = np->put_tx_ctx;
 			bcnt = (size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : size;
-			np->put_tx_ctx->dma = pci_map_page(np->pci_dev, frag->page, frag->page_offset+offset, bcnt,
-							   PCI_DMA_TODEVICE);
+			np->put_tx_ctx->dma = skb_frag_dma_map(
+							&np->pci_dev->dev,
+							frag, offset,
+							bcnt,
+							PCI_DMA_TODEVICE);
 			np->put_tx_ctx->dma_len = bcnt;
 			np->put_tx_ctx->dma_single = 0;
 			put_tx->buf = cpu_to_le32(np->put_tx_ctx->dma);
@@ -2257,8 +2260,11 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 			prev_tx = put_tx;
 			prev_tx_ctx = np->put_tx_ctx;
 			bcnt = (size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : size;
-			np->put_tx_ctx->dma = pci_map_page(np->pci_dev, frag->page, frag->page_offset+offset, bcnt,
-							   PCI_DMA_TODEVICE);
+			np->put_tx_ctx->dma = skb_frag_dma_map(
+							&np->pci_dev->dev,
+							frag, offset,
+							bcnt,
+							PCI_DMA_TODEVICE);
 			np->put_tx_ctx->dma_len = bcnt;
 			np->put_tx_ctx->dma_single = 0;
 			put_tx->bufhigh = cpu_to_le32(dma_high(np->put_tx_ctx->dma));
-- 
1.7.2.5
