From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/2] mlxsw: reg: Add the Switch Port Acceptable Frame Types register
Date: Thu, 18 Feb 2016 11:30:01 +0100
Message-ID: <1455791402-12976-2-git-send-email-jiri@resnulli.us>
References: <1455791402-12976-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:34843 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424770AbcBRKaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 05:30:07 -0500
Received: by mail-wm0-f47.google.com with SMTP id c200so19535083wme.0
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 02:30:07 -0800 (PST)
In-Reply-To: <1455791402-12976-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When VLAN filtering is enabled on a bridge and PVID is deleted from a
bridge port, then untagged frames are not allowed to ingress into the
bridge from this port.

Add the Switch Port Acceptable Frame Types (SPAFT) register, which
configures the frame admittance of the port.

Fixes: 56ade8fe3fe1 ("mlxsw: spectrum: Add initial support for Spectrum ASIC")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 58 +++++++++++++++++++++++++++++++
 1 file changed, 58 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index bb77e22..ffe4c03 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -873,6 +873,62 @@ static inline void mlxsw_reg_spvm_pack(char *payload, u8 local_port,
 	}
 }
 
+/* SPAFT - Switch Port Acceptable Frame Types
+ * ------------------------------------------
+ * The Switch Port Acceptable Frame Types register configures the frame
+ * admittance of the port.
+ */
+#define MLXSW_REG_SPAFT_ID 0x2010
+#define MLXSW_REG_SPAFT_LEN 0x08
+
+static const struct mlxsw_reg_info mlxsw_reg_spaft = {
+	.id = MLXSW_REG_SPAFT_ID,
+	.len = MLXSW_REG_SPAFT_LEN,
+};
+
+/* reg_spaft_local_port
+ * Local port number.
+ * Access: Index
+ *
+ * Note: CPU port is not supported (all tag types are allowed).
+ */
+MLXSW_ITEM32(reg, spaft, local_port, 0x00, 16, 8);
+
+/* reg_spaft_sub_port
+ * Virtual port within the physical port.
+ * Should be set to 0 when virtual ports are not enabled on the port.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, spaft, sub_port, 0x00, 8, 8);
+
+/* reg_spaft_allow_untagged
+ * When set, untagged frames on the ingress are allowed (default).
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, spaft, allow_untagged, 0x04, 31, 1);
+
+/* reg_spaft_allow_prio_tagged
+ * When set, priority tagged frames on the ingress are allowed (default).
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, spaft, allow_prio_tagged, 0x04, 30, 1);
+
+/* reg_spaft_allow_tagged
+ * When set, tagged frames on the ingress are allowed (default).
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, spaft, allow_tagged, 0x04, 29, 1);
+
+static inline void mlxsw_reg_spaft_pack(char *payload, u8 local_port,
+					bool allow_untagged)
+{
+	MLXSW_REG_ZERO(spaft, payload);
+	mlxsw_reg_spaft_local_port_set(payload, local_port);
+	mlxsw_reg_spaft_allow_untagged_set(payload, allow_untagged);
+	mlxsw_reg_spaft_allow_prio_tagged_set(payload, true);
+	mlxsw_reg_spaft_allow_tagged_set(payload, true);
+}
+
 /* SFGC - Switch Flooding Group Configuration
  * ------------------------------------------
  * The following register controls the association of flooding tables and MIDs
@@ -3203,6 +3259,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "SPVID";
 	case MLXSW_REG_SPVM_ID:
 		return "SPVM";
+	case MLXSW_REG_SPAFT_ID:
+		return "SPAFT";
 	case MLXSW_REG_SFGC_ID:
 		return "SFGC";
 	case MLXSW_REG_SFTR_ID:
-- 
2.5.0
