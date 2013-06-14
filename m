From: Isaku Yamahata <yamahata@valinux.co.jp>
Subject: [PATCH net-next 3/5] mv643xx_eth.c: convert skb->end into skb_end_poitner(skb)
Date: Fri, 14 Jun 2013 17:58:33 +0900
Message-ID: <7629c2a65cffd7b61d100703567e027a2850c3c6.1371200138.git.yamahata@valinux.co.jp>
References: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
Cc: yamahata@valinux.co.jp, Simon Horman <horms@verge.net.au>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.valinux.co.jp ([210.128.90.3]:39006 "EHLO
	mail.valinux.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299Ab3FNI6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 04:58:36 -0400
In-Reply-To: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
In-Reply-To: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
References: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The change set of 4305b541 "[SK_BUFF]: Convert skb->end to sk_buff_data_t"
converted skb->end from pointer to sk_buff_data_t.
The pointed value should be accessed via skb_end_pointer().

Since arm or ppc arch doesn't define NET_SKBUFF_DATA_USES_OFFSET,
skb->end is effectively pointer. So it doesn't cause a real problem.
But this patch is good for consistency.

Found by inspection. Compile test only.

Cc: Simon Horman <horms@verge.net.au>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index c7f9fb3..510d506 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -621,7 +621,7 @@ static int rxq_refill(struct rx_queue *rxq, int budget)
 
 		rx_desc = rxq->rx_desc_area + rx;
 
-		size = skb->end - skb->data;
+		size = skb_end_pointer(skb) - skb->data;
 		rx_desc->buf_ptr = dma_map_single(mp->dev->dev.parent,
 						  skb->data, size,
 						  DMA_FROM_DEVICE);
-- 
1.7.10.4
