From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 10/12] net/mlx5_core: Export flow steering API
Date: Wed,  6 Jan 2016 23:52:29 +0200
Message-ID: <1452117151-28572-11-git-send-email-saeedm@mellanox.com>
References: <1452117151-28572-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Moni Shoua <monis@mellanox.com>, saeedm@dev.mellanox.co.il,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:43884 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752320AbcAFVxq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 16:53:46 -0500
In-Reply-To: <1452117151-28572-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Add exports to flow steering API for mlx5_ib usage.
The following functions are exported:

1. mlx5_create_auto_grouped_flow_table - used to create flow
table with auto flow grouping management (create and destroy
flow groups). In auto-grouped flow tables, we create groups
automatically if needed (if we don't find an existing
flow group with same match criteria when we add new rule).

2. mlx5_destroy_flow_table - used to destroy  a flow table.

3. mlx5_add_flow_rule - used to add flow rule into a flow table.

4. mlx5_del_flow_rule - used to delete flow rule from its flow table.

5. mlx5_get_flow_namespace - used to get a handle to the required
namespace sub-tree.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Moni Shoua <monis@mellanox.com>
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 757725b..6f68dba 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -702,6 +702,7 @@ struct mlx5_flow_table *mlx5_create_auto_grouped_flow_table(struct mlx5_flow_nam
 
 	return ft;
 }
+EXPORT_SYMBOL(mlx5_create_auto_grouped_flow_table);
 
 /* Flow table should be locked */
 static struct mlx5_flow_group *create_flow_group_common(struct mlx5_flow_table *ft,
@@ -1013,11 +1014,13 @@ unlock:
 	unlock_ref_node(&ft->node);
 	return rule;
 }
+EXPORT_SYMBOL(mlx5_add_flow_rule);
 
 void mlx5_del_flow_rule(struct mlx5_flow_rule *rule)
 {
 	tree_remove_node(&rule->node);
 }
+EXPORT_SYMBOL(mlx5_del_flow_rule);
 
 /* Assuming prio->node.children(flow tables) is sorted by level */
 static struct mlx5_flow_table *find_next_ft(struct mlx5_flow_table *ft)
@@ -1099,6 +1102,7 @@ int mlx5_destroy_flow_table(struct mlx5_flow_table *ft)
 
 	return err;
 }
+EXPORT_SYMBOL(mlx5_destroy_flow_table);
 
 void mlx5_destroy_flow_group(struct mlx5_flow_group *fg)
 {
@@ -1143,6 +1147,7 @@ struct mlx5_flow_namespace *mlx5_get_flow_namespace(struct mlx5_core_dev *dev,
 
 	return ns;
 }
+EXPORT_SYMBOL(mlx5_get_flow_namespace);
 
 static struct fs_prio *fs_create_prio(struct mlx5_flow_namespace *ns,
 				      unsigned prio, int max_ft)
-- 
1.7.1
