From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 4/9] net/mlx5e: Device's mtu field is u16 and not int
Date: Tue, 19 Apr 2016 15:33:37 +0300
Message-ID: <1461069222-27076-5-git-send-email-saeedm@mellanox.com>
References: <1461069222-27076-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:48494 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754113AbcDSMfF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2016 08:35:05 -0400
In-Reply-To: <1461069222-27076-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For set/query MTU port firmware commands the MTU field
is 16 bits, here I changed all the "int mtu" parameters
of the functions wrapping those firmware commands to be u16.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/port.c    |   10 +++++-----
 include/linux/mlx5/port.h                         |    6 +++---
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index e0adb60..2fbbc62 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1408,7 +1408,7 @@ static int mlx5e_set_dev_port_mtu(struct net_device *netdev)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5_core_dev *mdev = priv->mdev;
-	int hw_mtu;
+	u16 hw_mtu;
 	int err;
 
 	err = mlx5_set_port_mtu(mdev, MLX5E_SW2HW_MTU(netdev->mtu), 1);
@@ -2004,7 +2004,7 @@ static int mlx5e_change_mtu(struct net_device *netdev, int new_mtu)
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5_core_dev *mdev = priv->mdev;
 	bool was_opened;
-	int max_mtu;
+	u16 max_mtu;
 	int err = 0;
 
 	mlx5_query_port_max_mtu(mdev, &max_mtu, 1);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index ae378c5..53cc1e2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -247,8 +247,8 @@ int mlx5_query_port_admin_status(struct mlx5_core_dev *dev,
 }
 EXPORT_SYMBOL_GPL(mlx5_query_port_admin_status);
 
-static void mlx5_query_port_mtu(struct mlx5_core_dev *dev, int *admin_mtu,
-				int *max_mtu, int *oper_mtu, u8 port)
+static void mlx5_query_port_mtu(struct mlx5_core_dev *dev, u16 *admin_mtu,
+				u16 *max_mtu, u16 *oper_mtu, u8 port)
 {
 	u32 in[MLX5_ST_SZ_DW(pmtu_reg)];
 	u32 out[MLX5_ST_SZ_DW(pmtu_reg)];
@@ -268,7 +268,7 @@ static void mlx5_query_port_mtu(struct mlx5_core_dev *dev, int *admin_mtu,
 		*admin_mtu = MLX5_GET(pmtu_reg, out, admin_mtu);
 }
 
-int mlx5_set_port_mtu(struct mlx5_core_dev *dev, int mtu, u8 port)
+int mlx5_set_port_mtu(struct mlx5_core_dev *dev, u16 mtu, u8 port)
 {
 	u32 in[MLX5_ST_SZ_DW(pmtu_reg)];
 	u32 out[MLX5_ST_SZ_DW(pmtu_reg)];
@@ -283,14 +283,14 @@ int mlx5_set_port_mtu(struct mlx5_core_dev *dev, int mtu, u8 port)
 }
 EXPORT_SYMBOL_GPL(mlx5_set_port_mtu);
 
-void mlx5_query_port_max_mtu(struct mlx5_core_dev *dev, int *max_mtu,
+void mlx5_query_port_max_mtu(struct mlx5_core_dev *dev, u16 *max_mtu,
 			     u8 port)
 {
 	mlx5_query_port_mtu(dev, NULL, max_mtu, NULL, port);
 }
 EXPORT_SYMBOL_GPL(mlx5_query_port_max_mtu);
 
-void mlx5_query_port_oper_mtu(struct mlx5_core_dev *dev, int *oper_mtu,
+void mlx5_query_port_oper_mtu(struct mlx5_core_dev *dev, u16 *oper_mtu,
 			      u8 port)
 {
 	mlx5_query_port_mtu(dev, NULL, NULL, oper_mtu, port);
diff --git a/include/linux/mlx5/port.h b/include/linux/mlx5/port.h
index a1d145a..b30250a 100644
--- a/include/linux/mlx5/port.h
+++ b/include/linux/mlx5/port.h
@@ -54,9 +54,9 @@ int mlx5_set_port_admin_status(struct mlx5_core_dev *dev,
 int mlx5_query_port_admin_status(struct mlx5_core_dev *dev,
 				 enum mlx5_port_status *status);
 
-int mlx5_set_port_mtu(struct mlx5_core_dev *dev, int mtu, u8 port);
-void mlx5_query_port_max_mtu(struct mlx5_core_dev *dev, int *max_mtu, u8 port);
-void mlx5_query_port_oper_mtu(struct mlx5_core_dev *dev, int *oper_mtu,
+int mlx5_set_port_mtu(struct mlx5_core_dev *dev, u16 mtu, u8 port);
+void mlx5_query_port_max_mtu(struct mlx5_core_dev *dev, u16 *max_mtu, u8 port);
+void mlx5_query_port_oper_mtu(struct mlx5_core_dev *dev, u16 *oper_mtu,
 			      u8 port);
 
 int mlx5_query_port_vl_hw_cap(struct mlx5_core_dev *dev,
-- 
1.7.1
