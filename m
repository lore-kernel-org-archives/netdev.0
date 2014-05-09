From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH 3/3] net: sxgbe: fixed mtl and dma channel feature
Date: Fri, 09 May 2014 11:03:49 +0900
Message-ID: <003d01cf6b2a$eb1fc500$c15f4f00$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'David Miller' <davem@davemloft.net>,
	"'ks.giri'" <ks.giri@samsung.com>,
	"'vipul.pandya'" <vipul.pandya@samsung.com>
To: 'netdev' <netdev@vger.kernel.org>,
	linux-samsung-soc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:46711 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754927AbaEICDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 22:03:50 -0400
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch fixes mtl queue and dma channel value
and adds mtl qsize for FIFO setting.

Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index 7dc3449..bf4447a 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -889,14 +889,19 @@ static int sxgbe_get_hw_features(struct sxgbe_priv_data * const priv)
 	/* Read First Capability Register CAP[2] */
 	rval = priv->hw->mac->get_hw_feature(priv->ioaddr, 2);
 	if (rval) {
-		features->rx_mtl_queues = SXGBE_HW_FEAT_RX_MTL_QUEUES(rval);
-		features->tx_mtl_queues = SXGBE_HW_FEAT_TX_MTL_QUEUES(rval);
-		features->rx_dma_channels = SXGBE_HW_FEAT_RX_DMA_CHANNELS(rval);
-		features->tx_dma_channels = SXGBE_HW_FEAT_TX_DMA_CHANNELS(rval);
+		features->rx_mtl_queues = SXGBE_HW_FEAT_RX_MTL_QUEUES(rval) + 1;
+		features->tx_mtl_queues = SXGBE_HW_FEAT_TX_MTL_QUEUES(rval) + 1;
+		features->rx_dma_channels = SXGBE_HW_FEAT_RX_DMA_CHANNELS(rval) + 1;
+		features->tx_dma_channels = SXGBE_HW_FEAT_TX_DMA_CHANNELS(rval) + 1;
 		features->pps_output_count = SXGBE_HW_FEAT_PPS_OUTPUTS(rval);
 		features->aux_input_count = SXGBE_HW_FEAT_AUX_SNAPSHOTS(rval);
 	}
 
+	features->rx_mtl_qsize = (1 << (features->rxfifo_size + 7)) /
+				  features->rx_mtl_queues;
+	features->tx_mtl_qsize = (1 << (features->txfifo_size + 7)) /
+				  features->tx_mtl_queues;
+
 	return rval;
 }
 
-- 
1.7.10.4
