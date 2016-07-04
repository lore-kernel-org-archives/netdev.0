From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/14] mlxsw: reg: Add Router Algorithmic LPM Tree Binding Register definition
Date: Mon,  4 Jul 2016 08:23:07 +0200
Message-ID: <1467613397-17140-5-git-send-email-jiri@resnulli.us>
References: <1467613397-17140-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33336 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753149AbcGDGXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 02:23:25 -0400
Received: by mail-wm0-f68.google.com with SMTP id r201so19140966wme.0
        for <netdev@vger.kernel.org>; Sun, 03 Jul 2016 23:23:25 -0700 (PDT)
In-Reply-To: <1467613397-17140-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This register is used to bind virtual router and protocol to an
allocated LPM tree.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 45 +++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 4ea608f..0b7b91f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -3579,6 +3579,49 @@ static inline void mlxsw_reg_ralst_bin_pack(char *payload, u8 bin_number,
 					    right_child_bin);
 }
 
+/* RALTB - Router Algorithmic LPM Tree Binding Register
+ * ----------------------------------------------------
+ * RALTB is used to bind virtual router and protocol to an allocated LPM tree.
+ */
+#define MLXSW_REG_RALTB_ID 0x8012
+#define MLXSW_REG_RALTB_LEN 0x04
+
+static const struct mlxsw_reg_info mlxsw_reg_raltb = {
+	.id = MLXSW_REG_RALTB_ID,
+	.len = MLXSW_REG_RALTB_LEN,
+};
+
+/* reg_raltb_virtual_router
+ * Virtual Router ID
+ * Range is 0..cap_max_virtual_routers-1
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, raltb, virtual_router, 0x00, 16, 16);
+
+/* reg_raltb_protocol
+ * Protocol.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, raltb, protocol, 0x00, 12, 4);
+
+/* reg_raltb_tree_id
+ * Tree to be used for the {virtual_router, protocol}
+ * Tree identifier numbered from 1..(cap_shspm_max_trees-1).
+ * By default, all Unicast IPv4 and IPv6 are bound to tree_id 0.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, raltb, tree_id, 0x00, 0, 8);
+
+static inline void mlxsw_reg_raltb_pack(char *payload, u16 virtual_router,
+					enum mlxsw_reg_ralxx_protocol protocol,
+					u8 tree_id)
+{
+	MLXSW_REG_ZERO(raltb, payload);
+	mlxsw_reg_raltb_virtual_router_set(payload, virtual_router);
+	mlxsw_reg_raltb_protocol_set(payload, protocol);
+	mlxsw_reg_raltb_tree_id_set(payload, tree_id);
+}
+
 /* MFCR - Management Fan Control Register
  * --------------------------------------
  * This register controls the settings of the Fan Speed PWM mechanism.
@@ -4325,6 +4368,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "RALTA";
 	case MLXSW_REG_RALST_ID:
 		return "RALST";
+	case MLXSW_REG_RALTB_ID:
+		return "RALTB";
 	case MLXSW_REG_MFCR_ID:
 		return "MFCR";
 	case MLXSW_REG_MFSC_ID:
-- 
2.5.5
