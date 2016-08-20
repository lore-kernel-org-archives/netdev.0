From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 29/30] net/mlx5: Introduce sniffer steering hardware capabilities
Date: Sat, 20 Aug 2016 23:12:12 +0300
Message-ID: <1471723933-5894-30-git-send-email-saeedm@mellanox.com>
References: <1471723933-5894-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Maor Gottlieb <maorg@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34263 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752323AbcHTUMw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2016 16:12:52 -0400
In-Reply-To: <1471723933-5894-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Define needed hardware capabilities for sniffer
RX and TX flow tables.

Add the following capabilities:
1. Sniffer RX flow table capabilities.
2. Sniffer TX flow table capabilities.
3. If same TIR can be used by multiple flow tables of different types.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
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
