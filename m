From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 09/22] net-next: mediatek: dropped rx packets are not being counted properly
Date: Mon,  9 May 2016 12:04:01 +0200
Message-ID: <1462788254-40572-10-git-send-email-john@phrozen.org>
References: <1462788254-40572-1-git-send-email-john@phrozen.org>
Cc: nbd@nbd.name, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, John Crispin <john@phrozen.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:47295 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751188AbcEIKEf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 06:04:35 -0400
In-Reply-To: <1462788254-40572-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are 2 places inside mtk_poll_rx where rx_dropped is not being
incremented properly. Fix this by adding the missing code to increment
the counter.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index e61e73b..75488d1 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -828,6 +828,7 @@ static int mtk_poll_rx(struct napi_struct *napi, int budget,
 					  DMA_FROM_DEVICE);
 		if (unlikely(dma_mapping_error(&netdev->dev, dma_addr))) {
 			skb_free_frag(new_data);
+			netdev->stats.rx_dropped++;
 			goto release_desc;
 		}
 
@@ -835,6 +836,7 @@ static int mtk_poll_rx(struct napi_struct *napi, int budget,
 		skb = build_skb(data, ring->frag_size);
 		if (unlikely(!skb)) {
 			put_page(virt_to_head_page(new_data));
+			netdev->stats.rx_dropped++;
 			goto release_desc;
 		}
 		skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
-- 
1.7.10.4
