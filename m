From: Isaku Yamahata <yamahata@valinux.co.jp>
Subject: [PATCH net-next 4/5] pxa168_eth: convert skb->end into skb_end_pointer(skb)
Date: Fri, 14 Jun 2013 17:58:34 +0900
Message-ID: <e9e0e51be02aec40989c4715466d0142381929fe.1371200138.git.yamahata@valinux.co.jp>
References: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
Cc: yamahata@valinux.co.jp, Simon Horman <horms@verge.net.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.valinux.co.jp ([210.128.90.3]:39011 "EHLO
	mail.valinux.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304Ab3FNI6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 04:58:36 -0400
In-Reply-To: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
In-Reply-To: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
References: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The change set of 4305b541, "[SK_BUFF]: Convert skb->end to sk_buff_data_t"
converted skb->end from pointer type to sk_buff_data_t.
The pointed value should be accessed via skb_end_pointer().

Since arm arch doesn't define NET_SKBUFF_DATA_USES_OFFSET,
skb->end is effectively pointer. So it doesn't cause a real problem.
But this patch is good for consistency.

Found by inspection. Compile tested only.

Cc: Simon Horman <horms@verge.net.au>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 drivers/net/ethernet/marvell/pxa168_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 2602cf7..ec20508 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -357,7 +357,7 @@ static void rxq_refill(struct net_device *dev)
 		/* Get 'used' Rx descriptor */
 		used_rx_desc = pep->rx_used_desc_q;
 		p_used_rx_desc = &pep->p_rx_desc_area[used_rx_desc];
-		size = skb->end - skb->data;
+		size = skb_end_pointer(skb) - skb->data;
 		p_used_rx_desc->buf_ptr = dma_map_single(NULL,
 							 skb->data,
 							 size,
-- 
1.7.10.4
