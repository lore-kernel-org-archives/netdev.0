From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 13/16] mlxsw: reg: Add Switch Virtual-Port Enabling register definition
Date: Fri, 16 Oct 2015 14:01:34 +0200
Message-ID: <1444996897-2708-14-git-send-email-jiri@resnulli.us>
References: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org, tgraf@suug.ch, jhs@mojatatu.com,
	sagir@mellanox.com, mattyk@mellanox.com, aviadr@mellanox.com
To: netdev@vger.kernel.org, ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:35621 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754018AbbJPMB5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 08:01:57 -0400
Received: by wicll6 with SMTP id ll6so6642713wic.0
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 05:01:56 -0700 (PDT)
In-Reply-To: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In order for a port to support {Port, VID} to FID mapping it needs to be
configured to a virtual port mode (as opposed to VLAN mode).

Add the SVPE register, which enables port virtualization.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 38 +++++++++++++++++++++++++++++++
 1 file changed, 38 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 5a97707..8e1888b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -976,6 +976,42 @@ static inline void mlxsw_reg_svfa_pack(char *payload, u8 local_port,
 	mlxsw_reg_svfa_vid_set(payload, vid);
 }
 
+/* SVPE - Switch Virtual-Port Enabling Register
+ * --------------------------------------------
+ * Enables port virtualization.
+ */
+#define MLXSW_REG_SVPE_ID 0x201E
+#define MLXSW_REG_SVPE_LEN 0x4
+
+static const struct mlxsw_reg_info mlxsw_reg_svpe = {
+	.id = MLXSW_REG_SVPE_ID,
+	.len = MLXSW_REG_SVPE_LEN,
+};
+
+/* reg_svpe_local_port
+ * Local port number
+ * Access: Index
+ *
+ * Note: CPU port is not supported (uses VLAN mode only).
+ */
+MLXSW_ITEM32(reg, svpe, local_port, 0x00, 16, 8);
+
+/* reg_svpe_vp_en
+ * Virtual port enable.
+ * 0 - Disable, VLAN mode (VID to FID).
+ * 1 - Enable, Virtual port mode ({Port, VID} to FID).
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, svpe, vp_en, 0x00, 8, 1);
+
+static inline void mlxsw_reg_svpe_pack(char *payload, u8 local_port,
+				       bool enable)
+{
+	MLXSW_REG_ZERO(svpe, payload);
+	mlxsw_reg_svpe_local_port_set(payload, local_port);
+	mlxsw_reg_svpe_vp_en_set(payload, enable);
+}
+
 /* SFMR - Switch FID Management Register
  * -------------------------------------
  * Creates and configures FIDs.
@@ -2241,6 +2277,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "SPMLR";
 	case MLXSW_REG_SVFA_ID:
 		return "SVFA";
+	case MLXSW_REG_SVPE_ID:
+		return "SVPE";
 	case MLXSW_REG_SFMR_ID:
 		return "SFMR";
 	case MLXSW_REG_PMLP_ID:
-- 
1.9.3
