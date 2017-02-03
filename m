From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 10/19] mlxsw: reg: Add Policy-Engine Extended Flexible Action Register
Date: Fri,  3 Feb 2017 10:29:00 +0100
Message-ID: <1486114149-7941-11-git-send-email-jiri@resnulli.us>
References: <1486114149-7941-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, ogerlitz@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, jbenc@redhat.com, tom@herbertland.com,
        f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:32963 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752542AbdBCJ3Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 04:29:24 -0500
Received: by mail-wm0-f67.google.com with SMTP id v77so3103228wmv.0
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 01:29:23 -0800 (PST)
In-Reply-To: <1486114149-7941-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

PEFA register is used for accessing an extended flexible action entry
in the central KVD Linear Database.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 39 ++++++++++++++++++++++++++++---
 1 file changed, 36 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index c503363..b50a312 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -2125,6 +2125,40 @@ static inline void mlxsw_reg_prcr_pack(char *payload, enum mlxsw_reg_prcr_op op,
 						       dest_tcam_region_info);
 }
 
+/* PEFA - Policy-Engine Extended Flexible Action Register
+ * ------------------------------------------------------
+ * This register is used for accessing an extended flexible action entry
+ * in the central KVD Linear Database.
+ */
+#define MLXSW_REG_PEFA_ID 0x300F
+#define MLXSW_REG_PEFA_LEN 0xB0
+
+MLXSW_REG_DEFINE(pefa, MLXSW_REG_PEFA_ID, MLXSW_REG_PEFA_LEN);
+
+/* reg_pefa_index
+ * Index in the KVD Linear Centralized Database.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, pefa, index, 0x00, 0, 24);
+
+#define MLXSW_REG_PXXX_FLEX_ACTION_SET_LEN 0xA8
+
+/* reg_pefa_flex_action_set
+ * Action-set to perform when rule is matched.
+ * Must be zero padded if action set is shorter.
+ * Access: RW
+ */
+MLXSW_ITEM_BUF(reg, pefa, flex_action_set, 0x08,
+	       MLXSW_REG_PXXX_FLEX_ACTION_SET_LEN);
+
+static inline void mlxsw_reg_pefa_pack(char *payload, u32 index,
+				       const char *flex_action_set)
+{
+	MLXSW_REG_ZERO(pefa, payload);
+	mlxsw_reg_pefa_index_set(payload, index);
+	mlxsw_reg_pefa_flex_action_set_memcpy_to(payload, flex_action_set);
+}
+
 /* PTCE-V2 - Policy-Engine TCAM Entry Register Version 2
  * -----------------------------------------------------
  * This register is used for accessing rules within a TCAM region.
@@ -2203,14 +2237,12 @@ MLXSW_ITEM_BUF(reg, ptce2, flex_key_blocks, 0x20,
 MLXSW_ITEM_BUF(reg, ptce2, mask, 0x80,
 	       MLXSW_REG_PTCE2_FLEX_KEY_BLOCKS_LEN);
 
-#define MLXSW_REG_PTCE2_FLEX_ACTION_SET_LEN 0xA8
-
 /* reg_ptce2_flex_action_set
  * ACL action set.
  * Access: RW
  */
 MLXSW_ITEM_BUF(reg, ptce2, flex_action_set, 0xE0,
-	       MLXSW_REG_PTCE2_FLEX_ACTION_SET_LEN);
+	       MLXSW_REG_PXXX_FLEX_ACTION_SET_LEN);
 
 static inline void mlxsw_reg_ptce2_pack(char *payload, bool valid,
 					enum mlxsw_reg_ptce2_op op,
@@ -5907,6 +5939,7 @@ static const struct mlxsw_reg_info *mlxsw_reg_infos[] = {
 	MLXSW_REG(ptar),
 	MLXSW_REG(ppbs),
 	MLXSW_REG(prcr),
+	MLXSW_REG(pefa),
 	MLXSW_REG(ptce2),
 	MLXSW_REG(qpcr),
 	MLXSW_REG(qtct),
-- 
2.7.4
