From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 07/13] net/mlx5: Move alloc/dealloc encap commands declarations to common header file
Date: Mon,  7 Nov 2016 15:14:42 +0200
Message-ID: <1478524488-1377-8-git-send-email-saeedm@mellanox.com>
References: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:39576 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753429AbcKGNPH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 08:15:07 -0500
In-Reply-To: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

The alloc and dealloc encap commands will be used in the mlx5e driver,
as such, declare them in a common header file.

Also, rename the functions: mlx5_cmd_{de}alloc_encap is replaced with
mlx5_encap_{de}alloc.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c    | 12 ++++++------
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h    |  7 -------
 drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h |  6 ++++++
 3 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index 113c323..6c9d99a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -455,11 +455,11 @@ void mlx5_cmd_fc_bulk_get(struct mlx5_core_dev *dev,
 
 #define MAX_ENCAP_SIZE (128)
 
-int mlx5_cmd_alloc_encap(struct mlx5_core_dev *dev,
-			 int header_type,
-			 size_t size,
-			 void *encap_header,
-			 u32 *encap_id)
+int mlx5_encap_alloc(struct mlx5_core_dev *dev,
+		     int header_type,
+		     size_t size,
+		     void *encap_header,
+		     u32 *encap_id)
 {
 	u32 out[MLX5_ST_SZ_DW(alloc_encap_header_out)];
 	u32 in[MLX5_ST_SZ_DW(alloc_encap_header_in) +
@@ -488,7 +488,7 @@ int mlx5_cmd_alloc_encap(struct mlx5_core_dev *dev,
 	return err;
 }
 
-void mlx5_cmd_dealloc_encap(struct mlx5_core_dev *dev, u32 encap_id)
+void mlx5_encap_dealloc(struct mlx5_core_dev *dev, u32 encap_id)
 {
 	u32 in[MLX5_ST_SZ_DW(dealloc_encap_header_in)];
 	u32 out[MLX5_ST_SZ_DW(dealloc_encap_header_out)];
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
index c5bc468..86bead1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
@@ -89,11 +89,4 @@ void mlx5_cmd_fc_bulk_get(struct mlx5_core_dev *dev,
 			  struct mlx5_cmd_fc_bulk *b, u16 id,
 			  u64 *packets, u64 *bytes);
 
-int mlx5_cmd_alloc_encap(struct mlx5_core_dev *dev,
-			 int header_type,
-			 size_t size,
-			 void *encap_header,
-			 u32 *encap_id);
-void mlx5_cmd_dealloc_encap(struct mlx5_core_dev *dev, u32 encap_id);
-
 #endif
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 1933b3c..4762bb9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -121,6 +121,12 @@ struct mlx5_core_dev *mlx5_get_next_phys_dev(struct mlx5_core_dev *dev);
 void mlx5_dev_list_lock(void);
 void mlx5_dev_list_unlock(void);
 int mlx5_dev_list_trylock(void);
+int mlx5_encap_alloc(struct mlx5_core_dev *dev,
+		     int header_type,
+		     size_t size,
+		     void *encap_header,
+		     u32 *encap_id);
+void mlx5_encap_dealloc(struct mlx5_core_dev *dev, u32 encap_id);
 
 bool mlx5_lag_intf_add(struct mlx5_interface *intf, struct mlx5_priv *priv);
 
-- 
2.7.4
