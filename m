From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 5/9] net/mlx5e: Use modify header ID cache for offloaded TC NIC flows
Date: Sun, 11 Jun 2017 17:55:49 +0300
Message-ID: <20170611145553.14180-6-saeedm@mellanox.com>
References: <20170611145553.14180-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46637 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751912AbdFKO4K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 10:56:10 -0400
In-Reply-To: <20170611145553.14180-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Use the modify header ID cache for the header re-write part of offloading
TC NIC flows.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 4625a0e226da..0c7a0872b22b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -251,10 +251,7 @@ mlx5e_tc_add_nic_flow(struct mlx5e_priv *priv,
 	}
 
 	if (attr->action & MLX5_FLOW_CONTEXT_ACTION_MOD_HDR) {
-		err = mlx5_modify_header_alloc(dev, MLX5_FLOW_NAMESPACE_KERNEL,
-					       parse_attr->num_mod_hdr_actions,
-					       parse_attr->mod_hdr_actions,
-					       &attr->mod_hdr_id);
+		err = mlx5e_attach_mod_hdr(priv, flow, parse_attr);
 		flow_act.modify_id = attr->mod_hdr_id;
 		kfree(parse_attr->mod_hdr_actions);
 		if (err) {
@@ -296,8 +293,7 @@ mlx5e_tc_add_nic_flow(struct mlx5e_priv *priv,
 	}
 err_create_ft:
 	if (attr->action & MLX5_FLOW_CONTEXT_ACTION_MOD_HDR)
-		mlx5_modify_header_dealloc(priv->mdev,
-					   attr->mod_hdr_id);
+		mlx5e_detach_mod_hdr(priv, flow);
 err_create_mod_hdr_id:
 	mlx5_fc_destroy(dev, counter);
 
@@ -320,8 +316,7 @@ static void mlx5e_tc_del_nic_flow(struct mlx5e_priv *priv,
 	}
 
 	if (attr->action & MLX5_FLOW_CONTEXT_ACTION_MOD_HDR)
-		mlx5_modify_header_dealloc(priv->mdev,
-					   attr->mod_hdr_id);
+		mlx5e_detach_mod_hdr(priv, flow);
 }
 
 static void mlx5e_detach_encap(struct mlx5e_priv *priv,
-- 
2.11.0
