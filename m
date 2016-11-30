From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next 6/8] net/mlx5e: Bring back representor's ndos that were accidentally removed
Date: Wed, 30 Nov 2016 16:41:33 +0200
Message-ID: <1480516895-29545-7-git-send-email-hadarh@mellanox.com>
References: <1480516895-29545-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46048 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755966AbcK3PhO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 10:37:14 -0500
In-Reply-To: <1480516895-29545-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VF Representor udp tunnel ndo entries were removed by mistake,
return them.

Fixes: 370bad0f9a52 ('net/mlx5e: Support HW (offloaded) and SW counters for SRIOV switchdev mode')
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 5e33f6b..9b1e351 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -384,6 +384,8 @@ int mlx5e_get_offload_stats(int attr_id, const struct net_device *dev,
 	.ndo_get_phys_port_name  = mlx5e_rep_get_phys_port_name,
 	.ndo_setup_tc            = mlx5e_rep_ndo_setup_tc,
 	.ndo_get_stats64         = mlx5e_rep_get_stats,
+	.ndo_udp_tunnel_add      = mlx5e_add_vxlan_port,
+	.ndo_udp_tunnel_del      = mlx5e_del_vxlan_port,
 	.ndo_has_offload_stats	 = mlx5e_has_offload_stats,
 	.ndo_get_offload_stats	 = mlx5e_get_offload_stats,
 };
-- 
1.8.3.1
