From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH] net: sxgbe: fixed mtl and dma channel feature
Date: Wed, 07 May 2014 17:13:59 +0900
Message-ID: <008a01cf69cc$4cd758e0$e6860aa0$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ks.giri@samsung.com, vipul.pandya@samsung.com
To: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:9489 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753889AbaEGIOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 04:14:03 -0400
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
