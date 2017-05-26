From: Jes Sorensen <jes.sorensen@gmail.com>
Subject: [PATCH 4/7] mlx5: Stub out eswitch offload vport functions
Date: Fri, 26 May 2017 17:16:21 -0400
Message-ID: <20170526211624.23133-5-jsorensen@fb.com>
References: <20170526211624.23133-1-jsorensen@fb.com>
Cc: kernel-team@fb.com, saeedm@mellanox.com, ilant@mellanox.com,
        Jes Sorensen <jsorensen@fb.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:36655 "EHLO
        mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948721AbdEZVQg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 17:16:36 -0400
Received: by mail-yw0-f196.google.com with SMTP id h82so1353241ywb.3
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 14:16:36 -0700 (PDT)
In-Reply-To: <20170526211624.23133-1-jsorensen@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code isn't called if CONFIG_MLX5_EN_ESWITCH_OFFLOADS isn't enabled

Signed-off-by: Jes Sorensen <jsorensen@fb.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h    | 20 +++++++++++++++++++-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c   |  2 ++
 2 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index c2b0c02..6397384 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -348,6 +348,7 @@ int mlx5_devlink_eswitch_inline_mode_get(struct devlink *devlink, u8 *mode);
 int mlx5_eswitch_inline_mode_get(struct mlx5_eswitch *esw, int nvfs, u8 *mode);
 int mlx5_devlink_eswitch_encap_mode_set(struct devlink *devlink, u8 encap);
 int mlx5_devlink_eswitch_encap_mode_get(struct devlink *devlink, u8 *encap);
+#ifdef CONFIG_MLX5_EN_ESWITCH_OFFLOADS
 void mlx5_eswitch_register_vport_rep(struct mlx5_eswitch *esw,
 				     int vport_index,
 				     struct mlx5_eswitch_rep *rep);
@@ -355,12 +356,29 @@ void mlx5_eswitch_unregister_vport_rep(struct mlx5_eswitch *esw,
 				       int vport_index);
 struct net_device *mlx5_eswitch_get_uplink_netdev(struct mlx5_eswitch *esw);
 
-#ifdef CONFIG_MLX5_EN_ESWITCH_OFFLOADS
 int mlx5_eswitch_add_vlan_action(struct mlx5_eswitch *esw,
 				 struct mlx5_esw_flow_attr *attr);
 int mlx5_eswitch_del_vlan_action(struct mlx5_eswitch *esw,
 				 struct mlx5_esw_flow_attr *attr);
 #else
+static inline void
+mlx5_eswitch_register_vport_rep(struct mlx5_eswitch *esw, int vport_index,
+				struct mlx5_eswitch_rep *rep)
+{
+	return;
+}
+static inline void
+mlx5_eswitch_unregister_vport_rep(struct mlx5_eswitch *esw, int vport_index)
+{
+	return;
+}
+
+static inline struct net_device *
+mlx5_eswitch_get_uplink_netdev(struct mlx5_eswitch *esw)
+{
+	return NULL;
+}
+
 static inline int mlx5_eswitch_add_vlan_action(struct mlx5_eswitch *esw,
 					       struct mlx5_esw_flow_attr *attr)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 12505ba..9278a33 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -1126,6 +1126,7 @@ int mlx5_devlink_eswitch_encap_mode_get(struct devlink *devlink, u8 *encap)
 	return 0;
 }
 
+#ifdef CONFIG_MLX5_EN_ESWITCH_OFFLOADS
 void mlx5_eswitch_register_vport_rep(struct mlx5_eswitch *esw,
 				     int vport_index,
 				     struct mlx5_eswitch_rep *__rep)
@@ -1170,3 +1171,4 @@ struct net_device *mlx5_eswitch_get_uplink_netdev(struct mlx5_eswitch *esw)
 	rep = &offloads->vport_reps[UPLINK_REP_INDEX];
 	return rep->netdev;
 }
+#endif
-- 
2.9.4
