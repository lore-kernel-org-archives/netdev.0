From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V2 net-next 01/10] net/mlx4_en: Set csum level for encapsulated packets
Date: Thu, 11 Dec 2014 10:57:51 +0200
Message-ID: <1418288280-334-2-git-send-email-ogerlitz@mellanox.com>
References: <1418288280-334-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40388 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932127AbaLKI6f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2014 03:58:35 -0500
In-Reply-To: <1418288280-334-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was dropped by mistake for the napi_gro_frags flow, fix that.

Fixes: dd65beac48a5 ('net/mlx4_en: Extend usage of napi_gro_frags')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 4ca396e..69a2e1b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -888,7 +888,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			gro_skb->ip_summed = ip_summed;
 
 			if (l2_tunnel && ip_summed == CHECKSUM_UNNECESSARY)
-				gro_skb->encapsulation = 1;
+				gro_skb->csum_level = 1;
+
 			if ((cqe->vlan_my_qpn &
 			    cpu_to_be32(MLX4_CQE_VLAN_PRESENT_MASK)) &&
 			    (dev->features & NETIF_F_HW_VLAN_CTAG_RX)) {
-- 
1.7.1
