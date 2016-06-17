From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 07/18] net/mlx5: Introduce nop steering commands
Date: Fri, 17 Jun 2016 17:43:48 +0300
Message-ID: <1466174639-14576-8-git-send-email-saeedm@mellanox.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57454 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932930AbcFQOrg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 10:47:36 -0400
In-Reply-To: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

All the nodes in the virtual namespaces exists only in software.
E.g. when we add flow rule with mlx5_add_flow_rule to virtual
namespace, the command of SET_FLOW_TABLE_ENTRY isn't called, the rule
will not be added to the hardware flow tables.

This virtual namespace merely exists in order to describe the RoCE
steering namespace.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c | 82 ++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h |  1 +
 2 files changed, 83 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index c3eecff..d6ea59d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -410,7 +410,72 @@ int mlx5_cmd_fc_query(struct mlx5_core_dev *dev, u16 id,
 	stats = MLX5_ADDR_OF(query_flow_counter_out, out, flow_statistics);
 	*packets = MLX5_GET64(traffic_counter, stats, packets);
 	*bytes = MLX5_GET64(traffic_counter, stats, octets);
+	return 0;
+}
+
+static int mlx5_cmd_virt_update_root_ft(struct mlx5_core_dev *dev,
+					struct mlx5_flow_table *ft)
+{
+	return 0;
+}
+
+static int mlx5_cmd_virt_create_flow_table(struct mlx5_core_dev *dev, u16 vport,
+					   enum fs_flow_table_type type, unsigned int level,
+					   unsigned int log_size, struct mlx5_flow_table
+					   *next_ft, unsigned int *table_id)
+{
+	return 0;
+}
+
+static int mlx5_cmd_virt_destroy_flow_table(struct mlx5_core_dev *dev,
+					    struct mlx5_flow_table *ft)
+{
+	return 0;
+}
+
+static int mlx5_cmd_virt_modify_flow_table(struct mlx5_core_dev *dev,
+					   struct mlx5_flow_table *ft,
+					   struct mlx5_flow_table *next_ft)
+{
+	return -EOPNOTSUPP;
+}
+
+static int mlx5_cmd_virt_create_flow_group(struct mlx5_core_dev *dev,
+					   struct mlx5_flow_table *ft,
+					   u32 *in,
+					   unsigned int *group_id)
+{
+	return 0;
+}
+
+static int mlx5_cmd_virt_destroy_flow_group(struct mlx5_core_dev *dev,
+					    struct mlx5_flow_table *ft,
+					    unsigned int group_id)
+{
+	return 0;
+}
 
+static int mlx5_cmd_virt_create_fte(struct mlx5_core_dev *dev,
+				    struct mlx5_flow_table *ft,
+				    unsigned int group_id,
+				    struct fs_fte *fte)
+{
+	return 0;
+}
+
+static int mlx5_cmd_virt_update_fte(struct mlx5_core_dev *dev,
+				    struct mlx5_flow_table *ft,
+				    unsigned int group_id,
+				    int modify_mask,
+				    struct fs_fte *fte)
+{
+	return -EOPNOTSUPP;
+}
+
+static int mlx5_cmd_virt_delete_fte(struct mlx5_core_dev *dev,
+				    struct mlx5_flow_table *ft,
+				    unsigned int index)
+{
 	return 0;
 }
 
@@ -426,7 +491,24 @@ static const struct steering_cmds steering_cmds = {
 	.delete_fte		= mlx5_cmd_delete_fte,
 };
 
+static const struct steering_cmds steering_virt_cmds = {
+	.update_root_ft		= mlx5_cmd_virt_update_root_ft,
+	.create_flow_table	= mlx5_cmd_virt_create_flow_table,
+	.destroy_flow_table	= mlx5_cmd_virt_destroy_flow_table,
+	.modify_flow_table	= mlx5_cmd_virt_modify_flow_table,
+	.create_flow_group	= mlx5_cmd_virt_create_flow_group,
+	.destroy_flow_group	= mlx5_cmd_virt_destroy_flow_group,
+	.create_fte		= mlx5_cmd_virt_create_fte,
+	.update_fte		= mlx5_cmd_virt_update_fte,
+	.delete_fte		= mlx5_cmd_virt_delete_fte,
+};
+
 const struct steering_cmds *mlx5_get_phys_fs_cmds(void)
 {
 	return &steering_cmds;
 }
+
+const struct steering_cmds *mlx5_get_virt_fs_cmds(void)
+{
+	return &steering_virt_cmds;
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
index b3f16ca..6896c5f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
@@ -67,6 +67,7 @@ struct steering_cmds {
 };
 
 const struct steering_cmds *mlx5_get_phys_fs_cmds(void);
+const struct steering_cmds *mlx5_get_virt_fs_cmds(void);
 
 int mlx5_cmd_fc_alloc(struct mlx5_core_dev *dev, u16 *id);
 int mlx5_cmd_fc_free(struct mlx5_core_dev *dev, u16 id);
-- 
2.8.0
