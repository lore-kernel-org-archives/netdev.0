From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 27/30] net/mlx5: Vport LAG creation support
Date: Sat, 20 Aug 2016 23:12:10 +0300
Message-ID: <1471723933-5894-28-git-send-email-saeedm@mellanox.com>
References: <1471723933-5894-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Aviv Heller <avivh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34289 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752420AbcHTUMx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2016 16:12:53 -0400
In-Reply-To: <1471723933-5894-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aviv Heller <avivh@mellanox.com>

Add interfaces for issuing CREATE_VPORT_LAG and
DESTROY_VPORT_LAG commands.

Used for receiving PF1's eth traffic on PF0's
root ft.

Signed-off-by: Aviv Heller <avivh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/lag.c | 22 ++++++++++++++++++++++
 include/linux/mlx5/driver.h                   |  2 ++
 2 files changed, 24 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/lag.c b/drivers/net/ethernet/mellanox/mlx5/core/lag.c
index 3cb570a..5fe320c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/lag.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/lag.c
@@ -110,6 +110,28 @@ static int mlx5_cmd_destroy_lag(struct mlx5_core_dev *dev)
 	return mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
 }
 
+int mlx5_cmd_create_vport_lag(struct mlx5_core_dev *dev)
+{
+	u32  in[MLX5_ST_SZ_DW(create_vport_lag_in)]  = {0};
+	u32 out[MLX5_ST_SZ_DW(create_vport_lag_out)] = {0};
+
+	MLX5_SET(create_vport_lag_in, in, opcode, MLX5_CMD_OP_CREATE_VPORT_LAG);
+
+	return mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
+}
+EXPORT_SYMBOL(mlx5_cmd_create_vport_lag);
+
+int mlx5_cmd_destroy_vport_lag(struct mlx5_core_dev *dev)
+{
+	u32  in[MLX5_ST_SZ_DW(destroy_vport_lag_in)]  = {0};
+	u32 out[MLX5_ST_SZ_DW(destroy_vport_lag_out)] = {0};
+
+	MLX5_SET(destroy_vport_lag_in, in, opcode, MLX5_CMD_OP_DESTROY_VPORT_LAG);
+
+	return mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
+}
+EXPORT_SYMBOL(mlx5_cmd_destroy_vport_lag);
+
 static struct mlx5_lag *mlx5_lag_dev_get(struct mlx5_core_dev *dev)
 {
 	return dev->priv.lag;
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index c568dd9..5cb9fa7 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -944,6 +944,8 @@ int mlx5_register_interface(struct mlx5_interface *intf);
 void mlx5_unregister_interface(struct mlx5_interface *intf);
 int mlx5_core_query_vendor_id(struct mlx5_core_dev *mdev, u32 *vendor_id);
 
+int mlx5_cmd_create_vport_lag(struct mlx5_core_dev *dev);
+int mlx5_cmd_destroy_vport_lag(struct mlx5_core_dev *dev);
 bool mlx5_lag_is_active(struct mlx5_core_dev *dev);
 struct net_device *mlx5_lag_get_roce_netdev(struct mlx5_core_dev *dev);
 
-- 
2.7.4
