From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 07/19] mlxsw: reg: Add Policy-Engine Port Binding Table
Date: Fri,  3 Feb 2017 10:28:57 +0100
Message-ID: <1486114149-7941-8-git-send-email-jiri@resnulli.us>
References: <1486114149-7941-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, ogerlitz@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, jbenc@redhat.com, tom@herbertland.com,
        f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35414 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752542AbdBCJ3U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 04:29:20 -0500
Received: by mail-wm0-f68.google.com with SMTP id u63so3087804wmu.2
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 01:29:20 -0800 (PST)
In-Reply-To: <1486114149-7941-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The PPBT is used for configuration of the Port Binding Table.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 63 +++++++++++++++++++++++++++++++
 1 file changed, 63 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 1008251..ce6d85a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -1757,6 +1757,68 @@ static inline void mlxsw_reg_spvmlr_pack(char *payload, u8 local_port,
 	}
 }
 
+/* PPBT - Policy-Engine Port Binding Table
+ * ---------------------------------------
+ * This register is used for configuration of the Port Binding Table.
+ */
+#define MLXSW_REG_PPBT_ID 0x3002
+#define MLXSW_REG_PPBT_LEN 0x14
+
+MLXSW_REG_DEFINE(ppbt, MLXSW_REG_PPBT_ID, MLXSW_REG_PPBT_LEN);
+
+enum mlxsw_reg_pxbt_e {
+	MLXSW_REG_PXBT_E_IACL,
+	MLXSW_REG_PXBT_E_EACL,
+};
+
+/* reg_ppbt_e
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, ppbt, e, 0x00, 31, 1);
+
+enum mlxsw_reg_pxbt_op {
+	MLXSW_REG_PXBT_OP_BIND,
+	MLXSW_REG_PXBT_OP_UNBIND,
+};
+
+/* reg_ppbt_op
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ppbt, op, 0x00, 28, 3);
+
+/* reg_ppbt_local_port
+ * Local port. Not including CPU port.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, ppbt, local_port, 0x00, 16, 8);
+
+/* reg_ppbt_g
+ * group - When set, the binding is of an ACL group. When cleared,
+ * the binding is of an ACL.
+ * Must be set to 1 for Spectrum.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ppbt, g, 0x10, 31, 1);
+
+/* reg_ppbt_acl_info
+ * ACL/ACL group identifier. If the g bit is set, this field should hold
+ * the acl_group_id, else it should hold the acl_id.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ppbt, acl_info, 0x10, 0, 16);
+
+static inline void mlxsw_reg_ppbt_pack(char *payload, enum mlxsw_reg_pxbt_e e,
+				       enum mlxsw_reg_pxbt_op op,
+				       u8 local_port, u16 acl_info)
+{
+	MLXSW_REG_ZERO(ppbt, payload);
+	mlxsw_reg_ppbt_e_set(payload, e);
+	mlxsw_reg_ppbt_op_set(payload, op);
+	mlxsw_reg_ppbt_local_port_set(payload, local_port);
+	mlxsw_reg_ppbt_g_set(payload, true);
+	mlxsw_reg_ppbt_acl_info_set(payload, acl_info);
+}
+
 /* PACL - Policy-Engine ACL Register
  * ---------------------------------
  * This register is used for configuration of the ACL.
@@ -5733,6 +5795,7 @@ static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
 	MLXSW_REG(svpe),
 	MLXSW_REG(sfmr),
 	MLXSW_REG(spvmlr),
+	MLXSW_REG(ppbt),
 	MLXSW_REG(pacl),
 	MLXSW_REG(pagt),
 	MLXSW_REG(ptar),
-- 
2.7.4
