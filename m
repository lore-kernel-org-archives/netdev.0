From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 5/6] net/mlx5: E-Switch, Set the actions for offloaded rules properly
Date: Fri,  4 Nov 2016 01:48:46 +0200
Message-ID: <1478216927-31328-6-git-send-email-saeedm@mellanox.com>
References: <1478216927-31328-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37671 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S933615AbcKCXuO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 19:50:14 -0400
In-Reply-To: <1478216927-31328-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

As for the current generation of the mlx5 HW (CX4/CX4-Lx) per flow vlan
push/pop actions are emulated, we must not program them to the firmware.

Fixes: f5f82476090f ('net/mlx5: E-Switch, Support VLAN actions in the offloads mode')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reported-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index c55ad8d..d239f5d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -57,7 +57,8 @@ mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 	if (esw->mode != SRIOV_OFFLOADS)
 		return ERR_PTR(-EOPNOTSUPP);
 
-	action = attr->action;
+	/* per flow vlan pop/push is emulated, don't set that into the firmware */
+	action = attr->action & ~(MLX5_FLOW_CONTEXT_ACTION_VLAN_PUSH | MLX5_FLOW_CONTEXT_ACTION_VLAN_POP);
 
 	if (action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) {
 		dest.type = MLX5_FLOW_DESTINATION_TYPE_VPORT;
-- 
2.7.4
