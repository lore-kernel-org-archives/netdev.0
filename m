From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 10/18] net/mlx5: Introduce get flow rule match API
Date: Fri, 17 Jun 2016 17:43:51 +0300
Message-ID: <1466174639-14576-11-git-send-email-saeedm@mellanox.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57481 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933457AbcFQOrp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 10:47:45 -0400
In-Reply-To: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Introduce API to get mlx5_flow_match which contains:
1. match_criteria_enable
2. match_criteria
3. match_value

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 19 +++++++++++++++++++
 include/linux/mlx5/fs.h                           |  3 +++
 2 files changed, 22 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index d60d578..b7ddcd2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -2077,3 +2077,22 @@ unlock:
 
 	return 0;
 }
+
+void mlx5_get_rule_flow_match(struct mlx5_flow_match *flow_match,
+			      struct mlx5_flow_rule *rule)
+{
+	struct mlx5_flow_group *fg;
+	struct fs_node *pnode;
+	struct fs_fte *fte;
+
+	pnode = rule->node.parent;
+	WARN_ON(!pnode);
+	fs_get_obj(fte, pnode);
+	pnode = pnode->parent;
+	WARN_ON(!pnode);
+	fs_get_obj(fg, pnode);
+
+	flow_match->match_value = fte->val;
+	flow_match->match_criteria = fg->mask.match_criteria;
+	flow_match->match_criteria_enable = fg->mask.match_criteria_enable;
+}
diff --git a/include/linux/mlx5/fs.h b/include/linux/mlx5/fs.h
index ae82e00..db1f06e 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -173,4 +173,7 @@ struct mlx5_event_data {
 	struct mlx5_flow_table *ft;
 	struct mlx5_flow_rule *rule;
 };
+
+void mlx5_get_rule_flow_match(struct mlx5_flow_match *flow_match,
+			      struct mlx5_flow_rule *rule);
 #endif
-- 
2.8.0
