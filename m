From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 4/8] mlxsw: reg: Adding SMID register
Date: Sun, 10 Jan 2016 21:06:25 +0100
Message-ID: <1452456389-2833-5-git-send-email-jiri@resnulli.us>
References: <1452456389-2833-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, corbet@lwn.net,
	stephen@networkplumber.org, sfeldma@gmail.com,
	vivien.didelot@savoirfairelinux.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38111 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757403AbcAJUGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 15:06:37 -0500
Received: by mail-wm0-f45.google.com with SMTP id b14so240499027wmb.1
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 12:06:36 -0800 (PST)
In-Reply-To: <1452456389-2833-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Adding back SMID register definition and packing. For each MC group a new
SMID entry will be generated.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 51 +++++++++++++++++++++++++++++++
 1 file changed, 51 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 9b79457..0c52372 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -99,6 +99,55 @@ static const struct mlxsw_reg_info mlxsw_reg_spad = {
  */
 MLXSW_ITEM_BUF(reg, spad, base_mac, 0x02, 6);
 
+/* SMID - Switch Multicast ID
+ * --------------------------
+ * The MID record maps from a MID (Multicast ID), which is a unique identifier
+ * of the multicast group within the stacking domain, into a list of local
+ * ports into which the packet is replicated.
+ */
+#define MLXSW_REG_SMID_ID 0x2007
+#define MLXSW_REG_SMID_LEN 0x240
+
+static const struct mlxsw_reg_info mlxsw_reg_smid = {
+	.id = MLXSW_REG_SMID_ID,
+	.len = MLXSW_REG_SMID_LEN,
+};
+
+/* reg_smid_swid
+ * Switch partition ID.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, smid, swid, 0x00, 24, 8);
+
+/* reg_smid_mid
+ * Multicast identifier - global identifier that represents the multicast group
+ * across all devices.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, smid, mid, 0x00, 0, 16);
+
+/* reg_smid_port
+ * Local port memebership (1 bit per port).
+ * Access: RW
+ */
+MLXSW_ITEM_BIT_ARRAY(reg, smid, port, 0x20, 0x20, 1);
+
+/* reg_smid_port_mask
+ * Local port mask (1 bit per port).
+ * Access: W
+ */
+MLXSW_ITEM_BIT_ARRAY(reg, smid, port_mask, 0x220, 0x20, 1);
+
+static inline void mlxsw_reg_smid_pack(char *payload, u16 mid,
+				       u8 port, bool set)
+{
+	MLXSW_REG_ZERO(smid, payload);
+	mlxsw_reg_smid_swid_set(payload, 0);
+	mlxsw_reg_smid_mid_set(payload, mid);
+	mlxsw_reg_smid_port_set(payload, port, set);
+	mlxsw_reg_smid_port_mask_set(payload, port, 1);
+}
+
 /* SSPR - Switch System Port Record Register
  * -----------------------------------------
  * Configures the system port to local port mapping.
@@ -3052,6 +3101,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "SGCR";
 	case MLXSW_REG_SPAD_ID:
 		return "SPAD";
+	case MLXSW_REG_SMID_ID:
+		return "SMID";
 	case MLXSW_REG_SSPR_ID:
 		return "SSPR";
 	case MLXSW_REG_SFDAT_ID:
-- 
1.9.3
