From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 1/4] net-next: mediatek: remove superfluous register reads
Date: Wed, 29 Jun 2016 13:38:08 +0200
Message-ID: <1467200291-60106-2-git-send-email-john@phrozen.org>
References: <1467200291-60106-1-git-send-email-john@phrozen.org>
Cc: Felix Fietkau <nbd@nbd.name>, Sean Wang <keyhaede@gmail.com>,
	netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	linux-kernel@vger.kernel.org, John Crispin <john@phrozen.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467200291-60106-1-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver was originally written for MIPS based SoC. These required the
IRQ mask register to be read after writing it to ensure that the content
was actually applied. As this version only works on ARM based SoCs, we can
safely remove the 2 reads as they are no longer required.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index d1cdc2d..5a3a4e9 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -332,8 +332,6 @@ static inline void mtk_irq_disable(struct mtk_eth *eth, u32 mask)
 
 	val = mtk_r32(eth, MTK_QDMA_INT_MASK);
 	mtk_w32(eth, val & ~mask, MTK_QDMA_INT_MASK);
-	/* flush write */
-	mtk_r32(eth, MTK_QDMA_INT_MASK);
 }
 
 static inline void mtk_irq_enable(struct mtk_eth *eth, u32 mask)
@@ -342,8 +340,6 @@ static inline void mtk_irq_enable(struct mtk_eth *eth, u32 mask)
 
 	val = mtk_r32(eth, MTK_QDMA_INT_MASK);
 	mtk_w32(eth, val | mask, MTK_QDMA_INT_MASK);
-	/* flush write */
-	mtk_r32(eth, MTK_QDMA_INT_MASK);
 }
 
 static int mtk_set_mac_address(struct net_device *dev, void *p)
-- 
1.7.10.4
