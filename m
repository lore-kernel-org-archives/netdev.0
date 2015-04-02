From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 04/18] net/mlx4: Aesthetic code changes in multi_func_init
Date: Thu,  2 Apr 2015 16:31:09 +0300
Message-ID: <1427981483-19317-5-git-send-email-ogerlitz@mellanox.com>
References: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Ido Shamay <idos@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:45672 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752660AbbDBNb5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2015 09:31:57 -0400
In-Reply-To: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

Previous vf_oper and vf_admin code created very long lines, making it hard
to read the code. Added relevant in-struct pointers to reduce code
complexity and avoid code lines spread over 80 lines. Same logic is preserved.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 20b3c7b..52bf0b5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -2213,6 +2213,9 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
 	}
 
 	if (mlx4_is_master(dev)) {
+		struct mlx4_vf_oper_state *vf_oper;
+		struct mlx4_vf_admin_state *vf_admin;
+
 		priv->mfunc.master.slave_state =
 			kzalloc(dev->num_slaves *
 				sizeof(struct mlx4_slave_state), GFP_KERNEL);
@@ -2232,6 +2235,8 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
 			goto err_comm_oper;
 
 		for (i = 0; i < dev->num_slaves; ++i) {
+			vf_admin = &priv->mfunc.master.vf_admin[i];
+			vf_oper = &priv->mfunc.master.vf_oper[i];
 			s_state = &priv->mfunc.master.slave_state[i];
 			s_state->last_cmd = MLX4_COMM_CMD_RESET;
 			for (j = 0; j < MLX4_EVENT_TYPES_NUM; ++j)
@@ -2242,6 +2247,9 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
 				     &priv->mfunc.comm[i].slave_read);
 			mmiowb();
 			for (port = 1; port <= MLX4_MAX_PORTS; port++) {
+				struct mlx4_vport_state *admin_vport;
+				struct mlx4_vport_state *oper_vport;
+
 				s_state->vlan_filter[port] =
 					kzalloc(sizeof(struct mlx4_vlan_fltr),
 						GFP_KERNEL);
@@ -2250,11 +2258,14 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
 						kfree(s_state->vlan_filter[port]);
 					goto err_slaves;
 				}
+
+				admin_vport = &vf_admin->vport[port];
+				oper_vport = &vf_oper->vport[port].state;
 				INIT_LIST_HEAD(&s_state->mcast_filters[port]);
-				priv->mfunc.master.vf_admin[i].vport[port].default_vlan = MLX4_VGT;
-				priv->mfunc.master.vf_oper[i].vport[port].state.default_vlan = MLX4_VGT;
-				priv->mfunc.master.vf_oper[i].vport[port].vlan_idx = NO_INDX;
-				priv->mfunc.master.vf_oper[i].vport[port].mac_idx = NO_INDX;
+				admin_vport->default_vlan = MLX4_VGT;
+				oper_vport->default_vlan = MLX4_VGT;
+				vf_oper->vport[port].vlan_idx = NO_INDX;
+				vf_oper->vport[port].mac_idx = NO_INDX;
 			}
 			spin_lock_init(&s_state->lock);
 		}
-- 
1.7.1
