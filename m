From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 03/12] net/mlx5: Introduce modify flow rule destination
Date: Fri, 29 Apr 2016 01:36:33 +0300
Message-ID: <1461883002-8912-4-git-send-email-saeedm@mellanox.com>
References: <1461883002-8912-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:33147 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751910AbcD1WiT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2016 18:38:19 -0400
In-Reply-To: <1461883002-8912-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

This API is used for modifying the flow rule destination.
This is needed for modifying the pointed flow table by the
traffic type classifier rules to point on the aRFS tables.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c |    4 ++--
 include/linux/mlx5/fs.h                           |    3 +++
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 89cce97..bb2c1cd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -615,8 +615,8 @@ static int update_root_ft_create(struct mlx5_flow_table *ft, struct fs_prio
 	return err;
 }
 
-static int mlx5_modify_rule_destination(struct mlx5_flow_rule *rule,
-					struct mlx5_flow_destination *dest)
+int mlx5_modify_rule_destination(struct mlx5_flow_rule *rule,
+				 struct mlx5_flow_destination *dest)
 {
 	struct mlx5_flow_table *ft;
 	struct mlx5_flow_group *fg;
diff --git a/include/linux/mlx5/fs.h b/include/linux/mlx5/fs.h
index 8dec550..28a5b66 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -113,4 +113,7 @@ mlx5_add_flow_rule(struct mlx5_flow_table *ft,
 		   struct mlx5_flow_destination *dest);
 void mlx5_del_flow_rule(struct mlx5_flow_rule *fr);
 
+int mlx5_modify_rule_destination(struct mlx5_flow_rule *rule,
+				 struct mlx5_flow_destination *dest);
+
 #endif
-- 
1.7.1
