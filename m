From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next V3 07/10] net/mlx5e: Add a new priority for kernel flow tables
Date: Tue,  8 Mar 2016 12:42:35 +0200
Message-ID: <1457433758-9193-8-git-send-email-amir@vadai.me>
References: <1457433758-9193-1-git-send-email-amir@vadai.me>
Cc: netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>, Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35182 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933181AbcCHKj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 05:39:26 -0500
Received: by mail-wm0-f68.google.com with SMTP id 1so3232594wmg.2
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2016 02:39:25 -0800 (PST)
In-Reply-To: <1457433758-9193-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the vlan and main flow tables to use priority 1. This will allow
the upcoming TC offload logic to use a higher priority (0) for the
offload steering table.

Signed-off-by: Amir Vadai <amir@vadai.me>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c   | 4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
index 80d81ab..d00a242 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
@@ -1041,7 +1041,7 @@ static int mlx5e_create_main_flow_table(struct mlx5e_priv *priv)
 	int err;
 
 	ft->num_groups = 0;
-	ft->t = mlx5_create_flow_table(priv->fts.ns, 0, MLX5E_MAIN_TABLE_SIZE);
+	ft->t = mlx5_create_flow_table(priv->fts.ns, 1, MLX5E_MAIN_TABLE_SIZE);
 
 	if (IS_ERR(ft->t)) {
 		err = PTR_ERR(ft->t);
@@ -1150,7 +1150,7 @@ static int mlx5e_create_vlan_flow_table(struct mlx5e_priv *priv)
 	int err;
 
 	ft->num_groups = 0;
-	ft->t = mlx5_create_flow_table(priv->fts.ns, 0, MLX5E_VLAN_TABLE_SIZE);
+	ft->t = mlx5_create_flow_table(priv->fts.ns, 1, MLX5E_VLAN_TABLE_SIZE);
 
 	if (IS_ERR(ft->t)) {
 		err = PTR_ERR(ft->t);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index f0e67d2..e848d70 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -73,8 +73,8 @@
 #define BY_PASS_MIN_LEVEL (KENREL_MIN_LEVEL + MLX5_BY_PASS_NUM_PRIOS +\
 			   LEFTOVERS_MAX_FT)
 
-#define KERNEL_MAX_FT 2
-#define KERNEL_NUM_PRIOS 1
+#define KERNEL_MAX_FT 3
+#define KERNEL_NUM_PRIOS 2
 #define KENREL_MIN_LEVEL 2
 
 struct node_caps {
-- 
2.7.0
