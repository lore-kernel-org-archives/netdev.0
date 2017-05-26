From: Jes Sorensen <jes.sorensen@gmail.com>
Subject: [PATCH 5/7] mlx5: Stub out create_vport_rx_rule when eswitch_offloads disabled
Date: Fri, 26 May 2017 17:16:22 -0400
Message-ID: <20170526211624.23133-6-jsorensen@fb.com>
References: <20170526211624.23133-1-jsorensen@fb.com>
Cc: kernel-team@fb.com, saeedm@mellanox.com, ilant@mellanox.com,
        Jes Sorensen <jsorensen@fb.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f193.google.com ([209.85.213.193]:36410 "EHLO
        mail-yb0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948722AbdEZVQh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 17:16:37 -0400
Received: by mail-yb0-f193.google.com with SMTP id n198so686173yba.3
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 14:16:37 -0700 (PDT)
In-Reply-To: <20170526211624.23133-1-jsorensen@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One more vport related function to disable.

Signed-off-by: Jes Sorensen <jsorensen@fb.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h          | 11 ++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c |  2 +-
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index 6397384..9a395f3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -295,6 +295,9 @@ void
 mlx5_eswitch_del_offloaded_rule(struct mlx5_eswitch *esw,
 				struct mlx5_flow_handle *rule,
 				struct mlx5_esw_flow_attr *attr);
+struct mlx5_flow_handle *
+mlx5_eswitch_create_vport_rx_rule(struct mlx5_eswitch *esw, int vport, u32 tirn);
+
 #else
 static inline struct mlx5_flow_handle *
 mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
@@ -310,11 +313,13 @@ mlx5_eswitch_del_offloaded_rule(struct mlx5_eswitch *esw,
 {
 	return;
 }
+static inline struct mlx5_flow_handle *
+mlx5_eswitch_create_vport_rx_rule(struct mlx5_eswitch *esw, int vport, u32 tirn)
+{
+	return ERR_PTR(-EOPNOTSUPP);
+}
 #endif
 
-struct mlx5_flow_handle *
-mlx5_eswitch_create_vport_rx_rule(struct mlx5_eswitch *esw, int vport, u32 tirn);
-
 enum {
 	SET_VLAN_STRIP	= BIT(0),
 	SET_VLAN_INSERT	= BIT(1)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 9278a33..2bda8f5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -670,7 +670,6 @@ static void esw_destroy_vport_rx_group(struct mlx5_eswitch *esw)
 {
 	mlx5_destroy_flow_group(esw->offloads.vport_rx_group);
 }
-#endif
 
 struct mlx5_flow_handle *
 mlx5_eswitch_create_vport_rx_rule(struct mlx5_eswitch *esw, int vport, u32 tirn)
@@ -710,6 +709,7 @@ mlx5_eswitch_create_vport_rx_rule(struct mlx5_eswitch *esw, int vport, u32 tirn)
 	kvfree(spec);
 	return flow_rule;
 }
+#endif
 
 static int esw_offloads_start(struct mlx5_eswitch *esw)
 {
-- 
2.9.4
