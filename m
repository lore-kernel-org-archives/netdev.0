From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/13] mlxsw: reg: Add Router Rules Copy Register
Date: Tue, 19 Sep 2017 10:00:17 +0200
Message-ID: <20170919080020.5870-11-jiri@resnulli.us>
References: <20170919080020.5870-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35693 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751622AbdISIAc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 04:00:32 -0400
Received: by mail-wr0-f194.google.com with SMTP id n64so1712901wrb.2
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 01:00:31 -0700 (PDT)
In-Reply-To: <20170919080020.5870-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

The RRCR register is used for copying and moving TCAM multicast routes
from different offsets. It will be used to allow routes relocation for
parman ops as part of the multicast router offloading logic.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 60 +++++++++++++++++++++++++++++++
 1 file changed, 60 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 046525e..31d120a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4680,6 +4680,65 @@ static inline void mlxsw_reg_ricnt_pack(char *payload, u32 index,
 					     MLXSW_REG_RICNT_COUNTER_SET_TYPE_BASIC);
 }
 
+/* RRCR - Router Rules Copy Register Layout
+ * ----------------------------------------
+ * This register is used for moving and copying route entry rules.
+ */
+#define MLXSW_REG_RRCR_ID 0x800F
+#define MLXSW_REG_RRCR_LEN 0x24
+
+MLXSW_REG_DEFINE(rrcr, MLXSW_REG_RRCR_ID, MLXSW_REG_RRCR_LEN);
+
+enum mlxsw_reg_rrcr_op {
+	/* Move rules */
+	MLXSW_REG_RRCR_OP_MOVE,
+	/* Copy rules */
+	MLXSW_REG_RRCR_OP_COPY,
+};
+
+/* reg_rrcr_op
+ * Access: WO
+ */
+MLXSW_ITEM32(reg, rrcr, op, 0x00, 28, 4);
+
+/* reg_rrcr_offset
+ * Offset within the region from which to copy/move.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, rrcr, offset, 0x00, 0, 16);
+
+/* reg_rrcr_size
+ * The number of rules to copy/move.
+ * Access: WO
+ */
+MLXSW_ITEM32(reg, rrcr, size, 0x04, 0, 16);
+
+/* reg_rrcr_table_id
+ * Identifier of the table on which to perform the operation. Encoding is the
+ * same as in RTAR.key_type
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, rrcr, table_id, 0x10, 0, 4);
+
+/* reg_rrcr_dest_offset
+ * Offset within the region to which to copy/move
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, rrcr, dest_offset, 0x20, 0, 16);
+
+static inline void mlxsw_reg_rrcr_pack(char *payload, enum mlxsw_reg_rrcr_op op,
+				       u16 offset, u16 size,
+				       enum mlxsw_reg_rtar_key_type table_id,
+				       u16 dest_offset)
+{
+	MLXSW_REG_ZERO(rrcr, payload);
+	mlxsw_reg_rrcr_op_set(payload, op);
+	mlxsw_reg_rrcr_offset_set(payload, offset);
+	mlxsw_reg_rrcr_size_set(payload, size);
+	mlxsw_reg_rrcr_table_id_set(payload, table_id);
+	mlxsw_reg_rrcr_dest_offset_set(payload, dest_offset);
+}
+
 /* RALTA - Router Algorithmic LPM Tree Allocation Register
  * -------------------------------------------------------
  * RALTA is used to allocate the LPM trees of the SHSPM method.
@@ -7133,6 +7192,7 @@ static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
 	MLXSW_REG(ratr),
 	MLXSW_REG(rtdp),
 	MLXSW_REG(ricnt),
+	MLXSW_REG(rrcr),
 	MLXSW_REG(ralta),
 	MLXSW_REG(ralst),
 	MLXSW_REG(raltb),
-- 
2.9.5
