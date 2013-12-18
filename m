From: Tom Herbert <therbert@google.com>
Subject: [PATCH 11/15] net: mlx4 calls skb_set_hash
Date: Tue, 17 Dec 2013 23:31:23 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1312172330420.24380@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f202.google.com ([209.85.161.202]:43217 "EHLO
	mail-gg0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014Ab3LRHbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 02:31:25 -0500
Received: by mail-gg0-f202.google.com with SMTP id a5so115661ggn.3
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 23:31:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_hash to set the hash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 07a1d0f..2aa0ae1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -747,7 +747,9 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 					}
 
 					if (dev->features & NETIF_F_RXHASH)
-						gro_skb->rxhash = be32_to_cpu(cqe->immed_rss_invalid);
+						skb_set_hash(gro_skb,
+							     be32_to_cpu(cqe->immed_rss_invalid),
+							     PKT_HASH_TYPE_L3);
 
 					skb_record_rx_queue(gro_skb, cq->ring);
 
@@ -789,7 +791,9 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		skb_record_rx_queue(skb, cq->ring);
 
 		if (dev->features & NETIF_F_RXHASH)
-			skb->rxhash = be32_to_cpu(cqe->immed_rss_invalid);
+			skb_set_hash(skb,
+				     be32_to_cpu(cqe->immed_rss_invalid),
+				     PKT_HASH_TYPE_L3);
 
 		if ((be32_to_cpu(cqe->vlan_my_qpn) &
 		    MLX4_CQE_VLAN_PRESENT_MASK) &&
-- 
1.8.5.1
