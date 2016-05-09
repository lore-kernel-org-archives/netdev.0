From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 17/22] net-next: mediatek: remove superfluous register reads
Date: Mon,  9 May 2016 12:04:09 +0200
Message-ID: <1462788254-40572-18-git-send-email-john@phrozen.org>
References: <1462788254-40572-1-git-send-email-john@phrozen.org>
Cc: nbd@nbd.name, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, John Crispin <john@phrozen.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:50398 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751377AbcEIK1f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 06:27:35 -0400
In-Reply-To: <1462788254-40572-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver was originally written for MIPS based SoC. These required the
IRQ mask register to be read after writing it to ensure that the content
was actually applied. As this version only works on ARM based SoC, we can
safely remove the 2 reads as they ware not required.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 74375a1..464a8ec 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -322,8 +322,6 @@ static inline void mtk_irq_disable(struct mtk_eth *eth, u32 mask)
 
 	val = mtk_r32(eth, MTK_QDMA_INT_MASK);
 	mtk_w32(eth, val & ~mask, MTK_QDMA_INT_MASK);
-	/* flush write */
-	mtk_r32(eth, MTK_QDMA_INT_MASK);
 }
 
 static inline void mtk_irq_enable(struct mtk_eth *eth, u32 mask)
@@ -332,8 +330,6 @@ static inline void mtk_irq_enable(struct mtk_eth *eth, u32 mask)
 
 	val = mtk_r32(eth, MTK_QDMA_INT_MASK);
 	mtk_w32(eth, val | mask, MTK_QDMA_INT_MASK);
-	/* flush write */
-	mtk_r32(eth, MTK_QDMA_INT_MASK);
 }
 
 static int mtk_set_mac_address(struct net_device *dev, void *p)
-- 
1.7.10.4
