From: John Crispin <john@phrozen.org>
Subject: [PATCH 1/4] net-next: mediatek: remove superfluous register reads
Date: Thu,  5 May 2016 11:27:40 +0200
Message-ID: <1462440463-52076-2-git-send-email-john@phrozen.org>
References: <1462440463-52076-1-git-send-email-john@phrozen.org>
Cc: nbd@nbd.name, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
	John Crispin <john@phrozen.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462440463-52076-1-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver was originally written for MIPS based SoC. These required the
IRQ mask register to be read after writing it to ensure that the content
was actually applied. As this version only works on ARM based SoC, we can
safely remove the 2 reads as they ware not required.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 4d0b179..bb7b78e 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -320,8 +320,6 @@ static inline void mtk_irq_disable(struct mtk_eth *eth, u32 mask)
 
 	val = mtk_r32(eth, MTK_QDMA_INT_MASK);
 	mtk_w32(eth, val & ~mask, MTK_QDMA_INT_MASK);
-	/* flush write */
-	mtk_r32(eth, MTK_QDMA_INT_MASK);
 }
 
 static inline void mtk_irq_enable(struct mtk_eth *eth, u32 mask)
@@ -330,8 +328,6 @@ static inline void mtk_irq_enable(struct mtk_eth *eth, u32 mask)
 
 	val = mtk_r32(eth, MTK_QDMA_INT_MASK);
 	mtk_w32(eth, val | mask, MTK_QDMA_INT_MASK);
-	/* flush write */
-	mtk_r32(eth, MTK_QDMA_INT_MASK);
 }
 
 static int mtk_set_mac_address(struct net_device *dev, void *p)
-- 
1.7.10.4
