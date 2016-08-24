From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next 14/15] net/mlx5: Introduce sniffer steering hardware capabilities
Date: Wed, 24 Aug 2016 13:39:13 +0300
Message-ID: <1472035154-14517-15-git-send-email-saeedm@mellanox.com>
References: <1472035154-14517-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Maor Gottlieb <maorg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1472035154-14517-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Maor Gottlieb <maorg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Define needed hardware capabilities for sniffer
RX and TX flow tables.

Add the following capabilities:
1. Sniffer RX flow table capabilities.
2. Sniffer TX flow table capabilities.
3. If same TIR can be used by multiple flow tables of different types.

Signed-off-by: Maor Gottlieb <maorg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/mlx5/device.h   | 12 ++++++++++++
 include/linux/mlx5/mlx5_ifc.h |  4 +++-
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 2575070..77c1417 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -964,6 +964,18 @@ enum mlx5_cap_type {
 #define MLX5_CAP_FLOWTABLE_NIC_RX_MAX(mdev, cap) \
 	MLX5_CAP_FLOWTABLE_MAX(mdev, flow_table_properties_nic_receive.cap)
 
+#define MLX5_CAP_FLOWTABLE_SNIFFER_RX(mdev, cap) \
+	MLX5_CAP_FLOWTABLE(mdev, flow_table_properties_nic_receive_sniffer.cap)
+
+#define MLX5_CAP_FLOWTABLE_SNIFFER_RX_MAX(mdev, cap) \
+	MLX5_CAP_FLOWTABLE_MAX(mdev, flow_table_properties_nic_receive_sniffer.cap)
+
+#define MLX5_CAP_FLOWTABLE_SNIFFER_TX(mdev, cap) \
+	MLX5_CAP_FLOWTABLE(mdev, flow_table_properties_nic_transmit_sniffer.cap)
+
+#define MLX5_CAP_FLOWTABLE_SNIFFER_TX_MAX(mdev, cap) \
+	MLX5_CAP_FLOWTABLE_MAX(mdev, flow_table_properties_nic_transmit_sniffer.cap)
+
 #define MLX5_CAP_ESW_FLOWTABLE(mdev, cap) \
 	MLX5_GET(flow_table_eswitch_cap, \
 		 mdev->hca_caps_cur[MLX5_CAP_ESWITCH_FLOW_TABLE], cap)
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 043d525..73a720f 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -483,7 +483,9 @@ struct mlx5_ifc_ads_bits {
 
 struct mlx5_ifc_flow_table_nic_cap_bits {
 	u8         nic_rx_multi_path_tirs[0x1];
-	u8         reserved_at_1[0x1ff];
+	u8         nic_rx_multi_path_tirs_fts[0x1];
+	u8         allow_sniffer_and_nic_rx_shared_tir[0x1];
+	u8         reserved_at_3[0x1fd];
 
 	struct mlx5_ifc_flow_table_prop_layout_bits flow_table_properties_nic_receive;
 
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
