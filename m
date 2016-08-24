From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next 12/15] net/mlx5: Vport LAG creation support
Date: Wed, 24 Aug 2016 13:39:11 +0300
Message-ID: <1472035154-14517-13-git-send-email-saeedm@mellanox.com>
References: <1472035154-14517-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Aviv Heller <avivh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1472035154-14517-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Aviv Heller <avivh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Add interfaces for issuing CREATE_VPORT_LAG and
DESTROY_VPORT_LAG commands.

Used for receiving PF1's eth traffic on PF0's
root ft.

Signed-off-by: Aviv Heller <avivh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
