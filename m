From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 7/8] mlx4: Set skb->csum_level for encapsulated
 checksum
Date: Mon, 25 Aug 2014 17:56:39 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1408251737350.5377@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:52481 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933663AbaHZA4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 20:56:40 -0400
Received: by mail-pa0-f73.google.com with SMTP id kx10so3723826pab.4
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 17:56:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set skb->csum_level instead of skb->encapsulation when indicating
CHECKSUM_UNNECESSARY for an encapsulated checksum.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 9c909d2..b7da466 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -769,7 +769,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 					gro_skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 					if (l2_tunnel)
-						gro_skb->encapsulation = 1;
+						gro_skb->csum_level = 1;
 					if ((cqe->vlan_my_qpn &
 					    cpu_to_be32(MLX4_CQE_VLAN_PRESENT_MASK)) &&
 					    (dev->features & NETIF_F_HW_VLAN_CTAG_RX)) {
@@ -823,8 +823,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		skb->protocol = eth_type_trans(skb, dev);
 		skb_record_rx_queue(skb, cq->ring);
 
-		if (l2_tunnel)
-			skb->encapsulation = 1;
+		if (l2_tunnel && ip_summed == CHECKSUM_UNNECESSARY)
+			skb->csum_level = 1;
 
 		if (dev->features & NETIF_F_RXHASH)
 			skb_set_hash(skb,
-- 
2.1.0.rc2.206.gedb03e5
