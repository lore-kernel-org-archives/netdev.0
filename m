From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 04/10] net/mlx5: Add DCBX firmware commands support
Date: Sat, 26 Nov 2016 16:18:28 +0200
Message-ID: <1480169914-22347-5-git-send-email-saeedm@mellanox.com>
References: <1480169914-22347-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Huy Nguyen <huyn@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41851 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751732AbcKZOTc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2016 09:19:32 -0500
In-Reply-To: <1480169914-22347-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huy Nguyen <huyn@mellanox.com>

Add set/query commands for DCBX_PARAM register

Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/port.c | 20 ++++++++++++++++++++
 include/linux/mlx5/driver.h                    |  7 +++++++
 include/linux/mlx5/port.h                      |  2 ++
 3 files changed, 29 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index ed4898f..d2ec9d2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -548,6 +548,26 @@ int mlx5_max_tc(struct mlx5_core_dev *mdev)
 	return num_tc - 1;
 }
 
+int mlx5_query_port_dcbx_param(struct mlx5_core_dev *mdev, u32 *out)
+{
+	u32 in[MLX5_ST_SZ_DW(dcbx_param)] = {0};
+
+	MLX5_SET(dcbx_param, in, port_number, 1);
+
+	return  mlx5_core_access_reg(mdev, in, sizeof(in), out,
+				    sizeof(in), MLX5_REG_DCBX_PARAM, 0, 0);
+}
+
+int mlx5_set_port_dcbx_param(struct mlx5_core_dev *mdev, u32 *in)
+{
+	u32 out[MLX5_ST_SZ_DW(dcbx_param)];
+
+	MLX5_SET(dcbx_param, in, port_number, 1);
+
+	return mlx5_core_access_reg(mdev, in, sizeof(out), out,
+				    sizeof(out), MLX5_REG_DCBX_PARAM, 0, 1);
+}
+
 int mlx5_set_port_prio_tc(struct mlx5_core_dev *mdev, u8 *prio_tc)
 {
 	u32 in[MLX5_ST_SZ_DW(qtct_reg)] = {0};
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index ae1f451..68b85ef 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -104,6 +104,8 @@ enum {
 enum {
 	MLX5_REG_QETCR		 = 0x4005,
 	MLX5_REG_QTCT		 = 0x400a,
+	MLX5_REG_DCBX_PARAM      = 0x4020,
+	MLX5_REG_DCBX_APP        = 0x4021,
 	MLX5_REG_PCAP		 = 0x5001,
 	MLX5_REG_PMTU		 = 0x5003,
 	MLX5_REG_PTYS		 = 0x5004,
@@ -124,6 +126,11 @@ enum {
 	MLX5_REG_MPCNT		 = 0x9051,
 };
 
+enum mlx5_dcbx_oper_mode {
+	MLX5E_DCBX_PARAM_VER_OPER_HOST  = 0x0,
+	MLX5E_DCBX_PARAM_VER_OPER_AUTO  = 0x3,
+};
+
 enum {
 	MLX5_ATOMIC_OPS_CMP_SWAP	= 1 << 0,
 	MLX5_ATOMIC_OPS_FETCH_ADD	= 1 << 1,
diff --git a/include/linux/mlx5/port.h b/include/linux/mlx5/port.h
index bdee439..e527732 100644
--- a/include/linux/mlx5/port.h
+++ b/include/linux/mlx5/port.h
@@ -162,4 +162,6 @@ void mlx5_query_port_fcs(struct mlx5_core_dev *mdev, bool *supported,
 int mlx5_query_module_eeprom(struct mlx5_core_dev *dev,
 			     u16 offset, u16 size, u8 *data);
 
+int mlx5_query_port_dcbx_param(struct mlx5_core_dev *mdev, u32 *out);
+int mlx5_set_port_dcbx_param(struct mlx5_core_dev *mdev, u32 *in);
 #endif /* __MLX5_PORT_H__ */
-- 
2.7.4
