From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 4/8] mlxsw: reg: Add Management Component Data Access register
Date: Tue, 23 May 2017 21:56:26 +0200
Message-ID: <20170523195630.6460-5-jiri@resnulli.us>
References: <20170523195630.6460-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
        mlxsw@mellanox.com, Yuval.Mintz@cavium.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36135 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968124AbdEWT4o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 15:56:44 -0400
Received: by mail-wm0-f67.google.com with SMTP id k15so40770598wmh.3
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 12:56:44 -0700 (PDT)
In-Reply-To: <20170523195630.6460-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

The MCDA register allows reading and writing a firmware component.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 52 +++++++++++++++++++++++++++++++
 1 file changed, 52 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index f3c768c..182150a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -5808,6 +5808,57 @@ static inline void mlxsw_reg_mcc_unpack(char *payload, u32 *p_update_handle,
 		*p_control_state = mlxsw_reg_mcc_control_state_get(payload);
 }
 
+/* MCDA - Management Component Data Access
+ * ---------------------------------------
+ * This register allows reading and writing a firmware component.
+ */
+#define MLXSW_REG_MCDA_ID 0x9063
+#define MLXSW_REG_MCDA_BASE_LEN 0x10
+#define MLXSW_REG_MCDA_MAX_DATA_LEN 0x80
+#define MLXSW_REG_MCDA_LEN \
+		(MLXSW_REG_MCDA_BASE_LEN + MLXSW_REG_MCDA_MAX_DATA_LEN)
+
+MLXSW_REG_DEFINE(mcda, MLXSW_REG_MCDA_ID, MLXSW_REG_MCDA_LEN);
+
+/* reg_mcda_update_handle
+ * Token representing the current flow executed by the FSM.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mcda, update_handle, 0x00, 0, 24);
+
+/* reg_mcda_offset
+ * Offset of accessed address relative to component start. Accesses must be in
+ * accordance to log_mcda_word_size in MCQI reg.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mcda, offset, 0x04, 0, 32);
+
+/* reg_mcda_size
+ * Size of the data accessed, given in bytes.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, mcda, size, 0x08, 0, 16);
+
+/* reg_mcda_data
+ * Data block accessed.
+ * Access: RW
+ */
+MLXSW_ITEM32_INDEXED(reg, mcda, data, 0x10, 0, 32, 4, 0, false);
+
+static inline void mlxsw_reg_mcda_pack(char *payload, u32 update_handle,
+				       u32 offset, u16 size, u8 *data)
+{
+	int i;
+
+	MLXSW_REG_ZERO(mcda, payload);
+	mlxsw_reg_mcda_update_handle_set(payload, update_handle);
+	mlxsw_reg_mcda_offset_set(payload, offset);
+	mlxsw_reg_mcda_size_set(payload, size);
+
+	for (i = 0; i < size / 4; i++)
+		mlxsw_reg_mcda_data_set(payload, i, *(u32 *) &data[i * 4]);
+}
+
 /* MPSC - Monitoring Packet Sampling Configuration Register
  * --------------------------------------------------------
  * MPSC Register is used to configure the Packet Sampling mechanism.
@@ -6388,6 +6439,7 @@ static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
 	MLXSW_REG(mpsc),
 	MLXSW_REG(mcqi),
 	MLXSW_REG(mcc),
+	MLXSW_REG(mcda),
 	MLXSW_REG(mgpc),
 	MLXSW_REG(sbpr),
 	MLXSW_REG(sbcm),
-- 
2.9.3
