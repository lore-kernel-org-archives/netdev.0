From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 04/19] mlxsw: reg: Add Policy-Engine ACL Group Table register
Date: Fri,  3 Feb 2017 10:28:54 +0100
Message-ID: <1486114149-7941-5-git-send-email-jiri@resnulli.us>
References: <1486114149-7941-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, ogerlitz@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, jbenc@redhat.com, tom@herbertland.com,
        f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:32882 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752452AbdBCJ3R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 04:29:17 -0500
Received: by mail-wm0-f65.google.com with SMTP id v77so3102466wmv.0
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 01:29:16 -0800 (PST)
In-Reply-To: <1486114149-7941-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The PAGT register is used for configuration of the ACL Group Table.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 54 +++++++++++++++++++++++++++++++
 1 file changed, 54 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 18b2da4..5f76fbc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -1799,6 +1799,59 @@ static inline void mlxsw_reg_pacl_pack(char *payload, u16 acl_id,
 	mlxsw_reg_pacl_tcam_region_info_memcpy_to(payload, tcam_region_info);
 }
 
+/* PAGT - Policy-Engine ACL Group Table
+ * ------------------------------------
+ * This register is used for configuration of the ACL Group Table.
+ */
+#define MLXSW_REG_PAGT_ID 0x3005
+#define MLXSW_REG_PAGT_BASE_LEN 0x30
+#define MLXSW_REG_PAGT_ACL_LEN 4
+#define MLXSW_REG_PAGT_ACL_MAX_NUM 16
+#define MLXSW_REG_PAGT_LEN (MLXSW_REG_PAGT_BASE_LEN + \
+		MLXSW_REG_PAGT_ACL_MAX_NUM * MLXSW_REG_PAGT_ACL_LEN)
+
+MLXSW_REG_DEFINE(pagt, MLXSW_REG_PAGT_ID, MLXSW_REG_PAGT_LEN);
+
+/* reg_pagt_size
+ * Number of ACLs in the group.
+ * Size 0 invalidates a group.
+ * Range 0 .. cap_max_acl_group_size (hard coded to 16 for now)
+ * Total number of ACLs in all groups must be lower or equal
+ * to cap_max_acl_tot_groups
+ * Note: a group which is binded must not be invalidated
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, pagt, size, 0x00, 0, 8);
+
+/* reg_pagt_acl_group_id
+ * An identifier (numbered from 0..cap_max_acl_groups-1) representing
+ * the ACL Group identifier (managed by software).
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, pagt, acl_group_id, 0x08, 0, 16);
+
+/* reg_pagt_acl_id
+ * ACL identifier
+ * Access: RW
+ */
+MLXSW_ITEM32_INDEXED(reg, pagt, acl_id, 0x30, 0, 16, 0x04, 0x00, false);
+
+static inline void mlxsw_reg_pagt_pack(char *payload, u16 acl_group_id)
+{
+	MLXSW_REG_ZERO(pagt, payload);
+	mlxsw_reg_pagt_acl_group_id_set(payload, acl_group_id);
+}
+
+static inline void mlxsw_reg_pagt_acl_id_pack(char *payload, int index,
+					      u16 acl_id)
+{
+	u8 size = mlxsw_reg_pagt_size_get(payload);
+
+	if (index >= size)
+		mlxsw_reg_pagt_size_set(payload, index + 1);
+	mlxsw_reg_pagt_acl_id_set(payload, index, acl_id);
+}
+
 /* QPCR - QoS Policer Configuration Register
  * -----------------------------------------
  * The QPCR register is used to create policers - that limit
@@ -5477,6 +5530,7 @@ static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
 	MLXSW_REG(sfmr),
 	MLXSW_REG(spvmlr),
 	MLXSW_REG(pacl),
+	MLXSW_REG(pagt),
 	MLXSW_REG(qpcr),
 	MLXSW_REG(qtct),
 	MLXSW_REG(qeec),
-- 
2.7.4
