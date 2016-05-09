From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 10/22] net-next: mediatek: add next data pointer coherency protection
Date: Mon,  9 May 2016 12:04:02 +0200
Message-ID: <1462788254-40572-11-git-send-email-john@phrozen.org>
References: <1462788254-40572-1-git-send-email-john@phrozen.org>
Cc: nbd@nbd.name, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, John Crispin <john@phrozen.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:50620 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751213AbcEIK3D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 06:29:03 -0400
In-Reply-To: <1462788254-40572-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The QDMA engine can fail to update the register pointing to the next TX
descriptor if this bit does not get set in the QDMA configuration register.
Not setting this bit can result in invalid values inside the TX rings
registers which will causes TX stalls.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    2 +-
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |    1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 75488d1..3ab7ab9 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1279,7 +1279,7 @@ static int mtk_start_dma(struct mtk_eth *eth)
 	mtk_w32(eth,
 		MTK_TX_WB_DDONE | MTK_RX_DMA_EN | MTK_TX_DMA_EN |
 		MTK_RX_2B_OFFSET | MTK_DMA_SIZE_16DWORDS |
-		MTK_RX_BT_32DWORDS,
+		MTK_RX_BT_32DWORDS | MTK_NDP_CO_PRO,
 		MTK_QDMA_GLO_CFG);
 
 	return 0;
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index 57f7e8a..a5eb7c6 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -91,6 +91,7 @@
 #define MTK_QDMA_GLO_CFG	0x1A04
 #define MTK_RX_2B_OFFSET	BIT(31)
 #define MTK_RX_BT_32DWORDS	(3 << 11)
+#define MTK_NDP_CO_PRO		BIT(10)
 #define MTK_TX_WB_DDONE		BIT(6)
 #define MTK_DMA_SIZE_16DWORDS	(2 << 4)
 #define MTK_RX_DMA_BUSY		BIT(3)
-- 
1.7.10.4
