From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 09/10] net/mlx5: E-Switch, Set the send-to-vport rules in the correct table
Date: Thu, 18 Aug 2016 21:09:10 +0300
Message-ID: <1471543751-24164-10-git-send-email-saeedm@mellanox.com>
References: <1471543751-24164-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41789 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754689AbcHSBnJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 21:43:09 -0400
In-Reply-To: <1471543751-24164-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

While adding actual offloading support to the new switchdev mode, we didn't
change the setup of the send-to-vport rules to put them in the slow path
table, fix that.

Fixes: 1033665e63b6 ('net/mlx5: E-Switch, Use two priorities for SRIOV offloads mode')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 1a3ccbf..3dc83a9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -113,7 +113,7 @@ mlx5_eswitch_add_send_to_vport_rule(struct mlx5_eswitch *esw, int vport, u32 sqn
 	dest.type = MLX5_FLOW_DESTINATION_TYPE_VPORT;
 	dest.vport_num = vport;
 
-	flow_rule = mlx5_add_flow_rule(esw->fdb_table.fdb, spec,
+	flow_rule = mlx5_add_flow_rule(esw->fdb_table.offloads.fdb, spec,
 				       MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
 				       0, &dest);
 	if (IS_ERR(flow_rule))
-- 
2.7.4
