From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 06/22] net-next: mediatek: add missing return code check
Date: Mon,  9 May 2016 12:03:58 +0200
Message-ID: <1462788254-40572-7-git-send-email-john@phrozen.org>
References: <1462788254-40572-1-git-send-email-john@phrozen.org>
Cc: nbd@nbd.name, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, John Crispin <john@phrozen.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:47257 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751270AbcEIKEa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 06:04:30 -0400
In-Reply-To: <1462788254-40572-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code fails to check if the scratch memory was properly allocated. Add
this check and return with an error if the allocation failed.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 4a01ba7..d16ec59 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -485,6 +485,9 @@ static int mtk_init_fq_dma(struct mtk_eth *eth)
 
 	eth->scratch_head = kcalloc(cnt, MTK_QDMA_PAGE_SIZE,
 				    GFP_KERNEL);
+	if (unlikely(!eth->scratch_head))
+		return -ENOMEM;
+
 	dma_addr = dma_map_single(eth->dev,
 				  eth->scratch_head, cnt * MTK_QDMA_PAGE_SIZE,
 				  DMA_FROM_DEVICE);
-- 
1.7.10.4
