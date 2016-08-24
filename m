From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next 03/15] net/mlx5: Expose mlx5e_link_mode
Date: Wed, 24 Aug 2016 13:39:02 +0300
Message-ID: <1472035154-14517-4-git-send-email-saeedm@mellanox.com>
References: <1472035154-14517-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Noa Osherovich <noaos-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Eran Ben Elisha <eranbe-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1472035154-14517-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Noa Osherovich <noaos-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

The mlx5e_link_mode enumeration will also be used in mlx5_ib for RoCE.
This patch moves the enumeration to the mlx5 driver port header file.

Signed-off-by: Noa Osherovich <noaos-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Eran Ben Elisha <eranbe-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h | 34 ----------------------------
 include/linux/mlx5/port.h                    | 33 +++++++++++++++++++++++++++
 2 files changed, 33 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 1b495ef..61902b1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -651,40 +651,6 @@ struct mlx5e_priv {
 	void                      *ppriv;
 };
 
-enum mlx5e_link_mode {
-	MLX5E_1000BASE_CX_SGMII	 = 0,
-	MLX5E_1000BASE_KX	 = 1,
-	MLX5E_10GBASE_CX4	 = 2,
-	MLX5E_10GBASE_KX4	 = 3,
-	MLX5E_10GBASE_KR	 = 4,
-	MLX5E_20GBASE_KR2	 = 5,
-	MLX5E_40GBASE_CR4	 = 6,
-	MLX5E_40GBASE_KR4	 = 7,
-	MLX5E_56GBASE_R4	 = 8,
-	MLX5E_10GBASE_CR	 = 12,
-	MLX5E_10GBASE_SR	 = 13,
-	MLX5E_10GBASE_ER	 = 14,
-	MLX5E_40GBASE_SR4	 = 15,
-	MLX5E_40GBASE_LR4	 = 16,
-	MLX5E_50GBASE_SR2	 = 18,
-	MLX5E_100GBASE_CR4	 = 20,
-	MLX5E_100GBASE_SR4	 = 21,
-	MLX5E_100GBASE_KR4	 = 22,
-	MLX5E_100GBASE_LR4	 = 23,
-	MLX5E_100BASE_TX	 = 24,
-	MLX5E_1000BASE_T	 = 25,
-	MLX5E_10GBASE_T		 = 26,
-	MLX5E_25GBASE_CR	 = 27,
-	MLX5E_25GBASE_KR	 = 28,
-	MLX5E_25GBASE_SR	 = 29,
-	MLX5E_50GBASE_CR2	 = 30,
-	MLX5E_50GBASE_KR2	 = 31,
-	MLX5E_LINK_MODES_NUMBER,
-};
-
-#define MLX5E_PROT_MASK(link_mode) (1 << link_mode)
-
-
 void mlx5e_build_ptys2ethtool_map(void);
 
 void mlx5e_send_nop(struct mlx5e_sq *sq, bool notify_hw);
diff --git a/include/linux/mlx5/port.h b/include/linux/mlx5/port.h
index e3012cc..6f876a4 100644
--- a/include/linux/mlx5/port.h
+++ b/include/linux/mlx5/port.h
@@ -61,6 +61,39 @@ enum mlx5_an_status {
 #define MLX5_I2C_ADDR_HIGH		0x51
 #define MLX5_EEPROM_PAGE_LENGTH		256
 
+enum mlx5e_link_mode {
+	MLX5E_1000BASE_CX_SGMII	 = 0,
+	MLX5E_1000BASE_KX	 = 1,
+	MLX5E_10GBASE_CX4	 = 2,
+	MLX5E_10GBASE_KX4	 = 3,
+	MLX5E_10GBASE_KR	 = 4,
+	MLX5E_20GBASE_KR2	 = 5,
+	MLX5E_40GBASE_CR4	 = 6,
+	MLX5E_40GBASE_KR4	 = 7,
+	MLX5E_56GBASE_R4	 = 8,
+	MLX5E_10GBASE_CR	 = 12,
+	MLX5E_10GBASE_SR	 = 13,
+	MLX5E_10GBASE_ER	 = 14,
+	MLX5E_40GBASE_SR4	 = 15,
+	MLX5E_40GBASE_LR4	 = 16,
+	MLX5E_50GBASE_SR2	 = 18,
+	MLX5E_100GBASE_CR4	 = 20,
+	MLX5E_100GBASE_SR4	 = 21,
+	MLX5E_100GBASE_KR4	 = 22,
+	MLX5E_100GBASE_LR4	 = 23,
+	MLX5E_100BASE_TX	 = 24,
+	MLX5E_1000BASE_T	 = 25,
+	MLX5E_10GBASE_T		 = 26,
+	MLX5E_25GBASE_CR	 = 27,
+	MLX5E_25GBASE_KR	 = 28,
+	MLX5E_25GBASE_SR	 = 29,
+	MLX5E_50GBASE_CR2	 = 30,
+	MLX5E_50GBASE_KR2	 = 31,
+	MLX5E_LINK_MODES_NUMBER,
+};
+
+#define MLX5E_PROT_MASK(link_mode) (1 << link_mode)
+
 int mlx5_set_port_caps(struct mlx5_core_dev *dev, u8 port_num, u32 caps);
 int mlx5_query_port_ptys(struct mlx5_core_dev *dev, u32 *ptys,
 			 int ptys_size, int proto_mask, u8 local_port);
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
