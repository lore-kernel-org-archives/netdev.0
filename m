From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next] net/mlx5_core: Fix static checker warnings around system guid query flow
Date: Sun,  7 Jun 2015 15:44:23 +0300
Message-ID: <1433681063-7472-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41156 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751152AbbFGMou (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Jun 2015 08:44:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Majd Dibbiny <majd@mellanox.com>

Fix static checker warnings in the flow of system guid query.

Fixes: 707c4602cda6 ('net/mlx5_core: Add new query HCA vport commands')
Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fw.c    |    3 ++-
 drivers/net/ethernet/mellanox/mlx5/core/vport.c |    2 +-
 include/linux/mlx5/vport.h                      |    2 +-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fw.c b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
index ba87442..9335e5a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
@@ -35,7 +35,8 @@
 #include <linux/module.h>
 #include "mlx5_core.h"
 
-int mlx5_cmd_query_adapter(struct mlx5_core_dev *dev, u32 *out, int outlen)
+static int mlx5_cmd_query_adapter(struct mlx5_core_dev *dev, u32 *out,
+				  int outlen)
 {
 	u32 in[MLX5_ST_SZ_DW(query_adapter_in)];
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vport.c b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
index 20150ff..b94177e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/vport.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
@@ -307,7 +307,7 @@ ex:
 EXPORT_SYMBOL_GPL(mlx5_query_hca_vport_context);
 
 int mlx5_query_hca_vport_system_image_guid(struct mlx5_core_dev *dev,
-					   __be64 *sys_image_guid)
+					   u64 *sys_image_guid)
 {
 	struct mlx5_hca_vport_context *rep;
 	int err;
diff --git a/include/linux/mlx5/vport.h b/include/linux/mlx5/vport.h
index 67882a8..967e0fd 100644
--- a/include/linux/mlx5/vport.h
+++ b/include/linux/mlx5/vport.h
@@ -48,7 +48,7 @@ int mlx5_query_hca_vport_context(struct mlx5_core_dev *dev,
 				 u16 vf_num,
 				 struct mlx5_hca_vport_context *rep);
 int mlx5_query_hca_vport_system_image_guid(struct mlx5_core_dev *dev,
-					   __be64 *sys_image_guid);
+					   u64 *sys_image_guid);
 int mlx5_query_hca_vport_node_guid(struct mlx5_core_dev *dev,
 				   u64 *node_guid);
 
-- 
1.7.1
