From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [for-next 11/12] net/mlx5e: IPoIB, Add PKEY child interface ethtool ops
Date: Sat, 14 Oct 2017 11:48:26 -0700
Message-ID: <20171014184827.18491-12-saeedm@mellanox.com>
References: <20171014184827.18491-1-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Alex Vesker <valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171014184827.18491-1-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alex Vesker <valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Similar to VLAN interfaces child interfaces have limited ethtool
support. In current code the main limitation that does not
allow child interface ethtool configuration is due to shared
resources which are managed by the parent.

Signed-off-by: Alex Vesker <valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Reviewed-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c    | 5 +++++
 drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h      | 1 +
 drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib_vlan.c | 4 ++--
 3 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c
index 43c126c63955..6f338a9219c8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c
@@ -250,3 +250,8 @@ const struct ethtool_ops mlx5i_ethtool_ops = {
 	.get_link_ksettings = mlx5i_get_link_ksettings,
 	.get_link           = ethtool_op_get_link,
 };
+
+const struct ethtool_ops mlx5i_pkey_ethtool_ops = {
+	.get_drvinfo        = mlx5i_get_drvinfo,
+	.get_link           = ethtool_op_get_link,
+};
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h
index 80c0cfee7164..a50c1a19550e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h
@@ -39,6 +39,7 @@
 #define MLX5I_MAX_NUM_TC 1
 
 extern const struct ethtool_ops mlx5i_ethtool_ops;
+extern const struct ethtool_ops mlx5i_pkey_ethtool_ops;
 
 #define MLX5_IB_GRH_BYTES       40
 #define MLX5_IPOIB_ENCAP_LEN    4
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib_vlan.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib_vlan.c
index d99bec6855de..531b02cc979b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib_vlan.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib_vlan.c
@@ -279,8 +279,8 @@ static void mlx5i_pkey_init(struct mlx5_core_dev *mdev,
 	/* Override parent ndo */
 	netdev->netdev_ops = &mlx5i_pkey_netdev_ops;
 
-	/* Currently no ethtool support */
-	netdev->ethtool_ops = NULL;
+	/* Set child limited ethtool support */
+	netdev->ethtool_ops = &mlx5i_pkey_ethtool_ops;
 
 	/* Use dummy rqs */
 	priv->channels.params.log_rq_size = MLX5E_PARAMS_MINIMUM_LOG_RQ_SIZE;
-- 
2.14.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
