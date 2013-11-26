From: Tom Herbert <therbert@google.com>
Subject: [PATCH 13/17] net: mlx4 calls skb_get_rxhash
Date: Mon, 25 Nov 2013 21:56:02 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311252154520.23058@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f74.google.com ([209.85.128.74]:42452 "EHLO
	mail-qe0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752669Ab3KZF4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 00:56:03 -0500
Received: by mail-qe0-f74.google.com with SMTP id b10so264378qen.5
        for <netdev@vger.kernel.org>; Mon, 25 Nov 2013 21:56:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_get_rxhash to set the rxhash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 07a1d0f..3e48c44 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -747,7 +747,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 					}
 
 					if (dev->features & NETIF_F_RXHASH)
-						gro_skb->rxhash = be32_to_cpu(cqe->immed_rss_invalid);
+						skb_set_rxhash(gro_skb, be32_to_cpu(cqe->immed_rss_invalid), RXHASH_TYPE_L3);
 
 					skb_record_rx_queue(gro_skb, cq->ring);
 
@@ -789,7 +789,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		skb_record_rx_queue(skb, cq->ring);
 
 		if (dev->features & NETIF_F_RXHASH)
-			skb->rxhash = be32_to_cpu(cqe->immed_rss_invalid);
+			skb_set_rxhash(skb, be32_to_cpu(cqe->immed_rss_invalid), RXHASH_TYPE_L3);
 
 		if ((be32_to_cpu(cqe->vlan_my_qpn) &
 		    MLX4_CQE_VLAN_PRESENT_MASK) &&
-- 
1.8.4.1
