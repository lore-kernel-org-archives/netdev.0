From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH] net: ethernet: ti: netcp_core: remove unused compl queue mapping
Date: Mon, 24 Apr 2017 23:54:06 +0300
Message-ID: <1493067246-3247-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-kernel@vger.kernel.org, grygorii.strashko@ti.com,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, w-kwok2@ti.com, m-karicheri2@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This code is unused and probably was unintentionally left while
moving completion queue mapping in submit function.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
Based on net-next/master

 drivers/net/ethernet/ti/netcp_core.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 9027c9c..729a7da 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1134,7 +1134,6 @@ netcp_tx_map_skb(struct sk_buff *skb, struct netcp_intf *netcp)
 		u32 buf_len = skb_frag_size(frag);
 		dma_addr_t desc_dma;
 		u32 desc_dma_32;
-		u32 pkt_info;
 
 		dma_addr = dma_map_page(dev, page, page_offset, buf_len,
 					DMA_TO_DEVICE);
@@ -1151,9 +1150,6 @@ netcp_tx_map_skb(struct sk_buff *skb, struct netcp_intf *netcp)
 		}
 
 		desc_dma = knav_pool_desc_virt_to_dma(netcp->tx_pool, ndesc);
-		pkt_info =
-			(netcp->tx_compl_qid & KNAV_DMA_DESC_RETQ_MASK) <<
-				KNAV_DMA_DESC_RETQ_SHIFT;
 		set_pkt_info(dma_addr, buf_len, 0, ndesc);
 		desc_dma_32 = (u32)desc_dma;
 		set_words(&desc_dma_32, 1, &pdesc->next_desc);
-- 
2.7.4
