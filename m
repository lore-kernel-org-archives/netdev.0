From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 13/17] net: mlx4 calls skb_set_rxhash
Date: Tue, 26 Nov 2013 09:31:50 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311260928050.21143@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f202.google.com ([209.85.220.202]:47093 "EHLO
	mail-vc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950Ab3KZRbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 12:31:51 -0500
Received: by mail-vc0-f202.google.com with SMTP id id10so632301vcb.3
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 09:31:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_rxhash to set the rxhash and its type
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
