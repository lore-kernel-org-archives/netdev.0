From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/19] mlxsw: reg: Add Policy-Engine Rules Copy Register
Date: Thu,  2 Feb 2017 16:12:48 +0100
Message-ID: <1486048379-19237-9-git-send-email-jiri@resnulli.us>
References: <1486048379-19237-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, ogerlitz@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, jbenc@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35627 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751668AbdBBPNR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 10:13:17 -0500
Received: by mail-wm0-f68.google.com with SMTP id u63so4802601wmu.2
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 07:13:16 -0800 (PST)
In-Reply-To: <1486048379-19237-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The PRCR register is used for accessing rules within a TCAM region.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 77 +++++++++++++++++++++++++++++++
 1 file changed, 77 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index ce6d85a..555cb80 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -2019,6 +2019,82 @@ static inline void mlxsw_reg_ptar_unpack(char *payload, char *tcam_region_info)
 	mlxsw_reg_ptar_tcam_region_info_memcpy_from(payload, tcam_region_info);
 }
 
+/* PRCR - Policy-Engine Rules Copy Register
+ * ----------------------------------------
+ * This register is used for accessing rules within a TCAM region.
+ */
+#define MLXSW_REG_PRCR_ID 0x300D
+#define MLXSW_REG_PRCR_LEN 0x40
+
+MLXSW_REG_DEFINE(prcr, MLXSW_REG_PRCR_ID, MLXSW_REG_PRCR_LEN);
+
+enum mlxsw_reg_prcr_op {
+	/* Move rules. Moves the rules from "tcam_region_info" starting
+	 * at offset "offset" to "dest_tcam_region_info"
+	 * at offset "dest_offset."
+	 */
+	MLXSW_REG_PRCR_OP_MOVE,
+	/* Copy rules. Copies the rules from "tcam_region_info" starting
+	 * at offset "offset" to "dest_tcam_region_info"
+	 * at offset "dest_offset."
+	 */
+	MLXSW_REG_PRCR_OP_COPY,
+};
+
+/* reg_prcr_op
+ * Access: OP
+ */
+MLXSW_ITEM32(reg, prcr, op, 0x00, 28, 4);
+
+/* reg_prcr_offset
+ * Offset within the source region to copy/move from.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, prcr, offset, 0x00, 0, 16);
+
+/* reg_prcr_size
+ * The number of rules to copy/move.
+ * Access: WO
+ */
+MLXSW_ITEM32(reg, prcr, size, 0x04, 0, 16);
+
+/* reg_prcr_tcam_region_info
+ * Opaque object that represents the source TCAM region.
+ * Access: Index
+ */
+MLXSW_ITEM_BUF(reg, prcr, tcam_region_info, 0x10,
+	       MLXSW_REG_PXXX_TCAM_REGION_INFO_LEN);
+
+/* reg_prcr_dest_offset
+ * Offset within the source region to copy/move to.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, prcr, dest_offset, 0x20, 0, 16);
+
+/* reg_prcr_dest_tcam_region_info
+ * Opaque object that represents the destination TCAM region.
+ * Access: Index
+ */
+MLXSW_ITEM_BUF(reg, prcr, dest_tcam_region_info, 0x30,
+	       MLXSW_REG_PXXX_TCAM_REGION_INFO_LEN);
+
+static inline void mlxsw_reg_prcr_pack(char *payload, enum mlxsw_reg_prcr_op op,
+				       const char *src_tcam_region_info,
+				       u16 src_offset,
+				       const char *dest_tcam_region_info,
+				       u16 dest_offset, u16 size)
+{
+	MLXSW_REG_ZERO(prcr, payload);
+	mlxsw_reg_prcr_op_set(payload, op);
+	mlxsw_reg_prcr_offset_set(payload, src_offset);
+	mlxsw_reg_prcr_size_set(payload, size);
+	mlxsw_reg_prcr_tcam_region_info_memcpy_to(payload,
+						  src_tcam_region_info);
+	mlxsw_reg_prcr_dest_offset_set(payload, dest_offset);
+	mlxsw_reg_prcr_dest_tcam_region_info_memcpy_to(payload,
+						       dest_tcam_region_info);
+}
+
 /* PTCE-V2 - Policy-Engine TCAM Entry Register Version 2
  * -----------------------------------------------------
  * This register is used for accessing rules within a TCAM region.
@@ -5799,6 +5875,7 @@ static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
 	MLXSW_REG(pacl),
 	MLXSW_REG(pagt),
 	MLXSW_REG(ptar),
+	MLXSW_REG(prcr),
 	MLXSW_REG(ptce2),
 	MLXSW_REG(qpcr),
 	MLXSW_REG(qtct),
-- 
2.7.4
