From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH 1/2] net: ethernet: altera: TSE: Remove unneeded dma sync for tx buffers
Date: Wed, 30 Nov 2016 23:48:31 +0100
Message-ID: <1480546112-3099-1-git-send-email-LinoSanfilippo@gmx.de>
Cc: nios2-dev@lists.rocketboards.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: vbridger@opensource.altera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

An explicit dma sync for device directly after mapping as well as an
explicit dma sync for cpu directly before unmapping is unnecessary and
costly on the hotpath. So remove these calls.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/net/ethernet/altera/altera_tse_main.c | 10 ----------
 1 file changed, 10 deletions(-)

 Please note that this is only compile tested since I do not have the
 concerning hardware.

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index bda31f3..16c4163 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -400,12 +400,6 @@ static int tse_rx(struct altera_tse_private *priv, int limit)
 
 		skb_put(skb, pktlength);
 
-		/* make cache consistent with receive packet buffer */
-		dma_sync_single_for_cpu(priv->device,
-					priv->rx_ring[entry].dma_addr,
-					priv->rx_ring[entry].len,
-					DMA_FROM_DEVICE);
-
 		dma_unmap_single(priv->device, priv->rx_ring[entry].dma_addr,
 				 priv->rx_ring[entry].len, DMA_FROM_DEVICE);
 
@@ -592,10 +586,6 @@ static int tse_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	buffer->dma_addr = dma_addr;
 	buffer->len = nopaged_len;
 
-	/* Push data out of the cache hierarchy into main memory */
-	dma_sync_single_for_device(priv->device, buffer->dma_addr,
-				   buffer->len, DMA_TO_DEVICE);
-
 	priv->dmaops->tx_buffer(priv, buffer);
 
 	skb_tx_timestamp(skb);
-- 
2.7.4
