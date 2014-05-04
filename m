From: Soren Brinkmann <soren.brinkmann@xilinx.com>
Subject: [PATCH 1/5] net: macb: Pass same size to DMA_UNMAP as used for DMA_MAP
Date: Sun,  4 May 2014 15:42:58 -0700
Message-ID: <1399243382-12528-2-git-send-email-soren.brinkmann@xilinx.com>
References: <1399243382-12528-1-git-send-email-soren.brinkmann@xilinx.com>
Cc: =?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
	git@xilinx.com, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Michal Simek <michal.simek@xilinx.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f50.google.com ([209.85.216.50]:57514 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753905AbaEDWoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 18:44:25 -0400
In-Reply-To: <1399243382-12528-1-git-send-email-soren.brinkmann@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just as commit "net: macb: DMA-unmap full rx-buffer"
(48330e08fa168395b9fd9f369f06cca1df204361), pass the size that
was used for mapping the memory also to the unmap routine to
avoid warnings from the DMA_API.

Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
---

 drivers/net/ethernet/cadence/macb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index ca97005e24b4..18fdcd9d51b3 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1113,7 +1113,7 @@ static void gem_free_rx_buffers(struct macb *bp)
 
 		desc = &bp->rx_ring[i];
 		addr = MACB_BF(RX_WADDR, MACB_BFEXT(RX_WADDR, desc->addr));
-		dma_unmap_single(&bp->pdev->dev, addr, skb->len,
+		dma_unmap_single(&bp->pdev->dev, addr, bp->rx_buffer_size,
 				 DMA_FROM_DEVICE);
 		dev_kfree_skb_any(skb);
 		skb = NULL;
-- 
1.9.2.1.g06c4abd
