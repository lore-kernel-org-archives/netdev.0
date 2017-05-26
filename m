From: Jes Sorensen <jes.sorensen@gmail.com>
Subject: [PATCH 6/7] mlx5: Stub out sqs2vport functions
Date: Fri, 26 May 2017 17:16:23 -0400
Message-ID: <20170526211624.23133-7-jsorensen@fb.com>
References: <20170526211624.23133-1-jsorensen@fb.com>
Cc: kernel-team@fb.com, saeedm@mellanox.com, ilant@mellanox.com,
        Jes Sorensen <jsorensen@fb.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:35127 "EHLO
        mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948724AbdEZVQi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 17:16:38 -0400
Received: by mail-yw0-f194.google.com with SMTP id p144so1348493ywp.2
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 14:16:37 -0700 (PDT)
In-Reply-To: <20170526211624.23133-1-jsorensen@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These aren't called if CONFIG_MLX5_EN_ESWITCH_OFFLOADS isn't enabled,
so do not build them.

Signed-off-by: Jes Sorensen <jsorensen@fb.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h          | 14 ++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c |  2 --
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index 9a395f3..f1a597b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -340,11 +340,25 @@ struct mlx5_esw_flow_attr {
 	struct mlx5e_tc_flow_parse_attr *parse_attr;
 };
 
+#ifdef CONFIG_MLX5_EN_ESWITCH_OFFLOADS
 int mlx5_eswitch_sqs2vport_start(struct mlx5_eswitch *esw,
 				 struct mlx5_eswitch_rep *rep,
 				 u16 *sqns_array, int sqns_num);
 void mlx5_eswitch_sqs2vport_stop(struct mlx5_eswitch *esw,
 				 struct mlx5_eswitch_rep *rep);
+#else
+static inline int mlx5_eswitch_sqs2vport_start(struct mlx5_eswitch *esw,
+					       struct mlx5_eswitch_rep *rep,
+					       u16 *sqns_array, int sqns_num)
+{
+	return -EOPNOTSUPP;
+}
+static inline void mlx5_eswitch_sqs2vport_stop(struct mlx5_eswitch *esw,
+					       struct mlx5_eswitch_rep *rep)
+{
+	return;
+}
+#endif
 
 int mlx5_devlink_eswitch_mode_set(struct devlink *devlink, u16 mode);
 int mlx5_devlink_eswitch_mode_get(struct devlink *devlink, u16 *mode);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 2bda8f5..638b84f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -302,7 +302,6 @@ int mlx5_eswitch_del_vlan_action(struct mlx5_eswitch *esw,
 out:
 	return err;
 }
-#endif
 
 static struct mlx5_flow_handle *
 mlx5_eswitch_add_send_to_vport_rule(struct mlx5_eswitch *esw, int vport, u32 sqn)
@@ -395,7 +394,6 @@ int mlx5_eswitch_sqs2vport_start(struct mlx5_eswitch *esw,
 	return err;
 }
 
-#ifdef CONFIG_MLX5_EN_ESWITCH_OFFLOADS
 static int esw_add_fdb_miss_rule(struct mlx5_eswitch *esw)
 {
 	struct mlx5_flow_act flow_act = {0};
-- 
2.9.4
