From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/12] mlxsw: reg: Add Router General Configuration Register
Date: Sat,  2 Jul 2016 11:00:13 +0200
Message-ID: <1467450020-23415-6-git-send-email-jiri@resnulli.us>
References: <1467450020-23415-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36318 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752202AbcGBJAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 05:00:31 -0400
Received: by mail-wm0-f66.google.com with SMTP id c82so10282429wme.3
        for <netdev@vger.kernel.org>; Sat, 02 Jul 2016 02:00:31 -0700 (PDT)
In-Reply-To: <1467450020-23415-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Add the Router General Configuration Register (RGCR), which allows us to
enable the router in the device and configure its various parameters.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 78 ++++++++++++++++++++++++++++++-
 1 file changed, 77 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 1977e7a..7f74eb7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -1,7 +1,7 @@
 /*
  * drivers/net/ethernet/mellanox/mlxsw/reg.h
  * Copyright (c) 2015 Mellanox Technologies. All rights reserved.
- * Copyright (c) 2015 Ido Schimmel <idosch@mellanox.com>
+ * Copyright (c) 2015-2016 Ido Schimmel <idosch@mellanox.com>
  * Copyright (c) 2015 Elad Raz <eladr@mellanox.com>
  * Copyright (c) 2015 Jiri Pirko <jiri@mellanox.com>
  *
@@ -3186,6 +3186,80 @@ static inline void mlxsw_reg_hpkt_pack(char *payload, u8 action, u16 trap_id)
 	mlxsw_reg_hpkt_ctrl_set(payload, MLXSW_REG_HPKT_CTRL_PACKET_DEFAULT);
 }
 
+/* RGCR - Router General Configuration Register
+ * --------------------------------------------
+ * The register is used for setting up the router configuration.
+ */
+#define MLXSW_REG_RGCR_ID 0x8001
+#define MLXSW_REG_RGCR_LEN 0x28
+
+static const struct mlxsw_reg_info mlxsw_reg_rgcr = {
+	.id = MLXSW_REG_RGCR_ID,
+	.len = MLXSW_REG_RGCR_LEN,
+};
+
+/* reg_rgcr_ipv4_en
+ * IPv4 router enable.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rgcr, ipv4_en, 0x00, 31, 1);
+
+/* reg_rgcr_ipv6_en
+ * IPv6 router enable.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rgcr, ipv6_en, 0x00, 30, 1);
+
+/* reg_rgcr_max_router_interfaces
+ * Defines the maximum number of active router interfaces for all virtual
+ * routers.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, rgcr, max_router_interfaces, 0x10, 0, 16);
+
+/* reg_rgcr_usp
+ * Update switch priority and packet color.
+ * 0 - Preserve the value of Switch Priority and packet color.
+ * 1 - Recalculate the value of Switch Priority and packet color.
+ * Access: RW
+ *
+ * Note: Not supported by SwitchX and SwitchX-2.
+ */
+MLXSW_ITEM32(reg, rgcr, usp, 0x18, 20, 1);
+
+/* reg_rgcr_pcp_rw
+ * Indicates how to handle the pcp_rewrite_en value:
+ * 0 - Preserve the value of pcp_rewrite_en.
+ * 2 - Disable PCP rewrite.
+ * 3 - Enable PCP rewrite.
+ * Access: RW
+ *
+ * Note: Not supported by SwitchX and SwitchX-2.
+ */
+MLXSW_ITEM32(reg, rgcr, pcp_rw, 0x18, 16, 2);
+
+/* reg_rgcr_activity_dis
+ * Activity disable:
+ * 0 - Activity will be set when an entry is hit (default).
+ * 1 - Activity will not be set when an entry is hit.
+ *
+ * Bit 0 - Disable activity bit in Router Algorithmic LPM Unicast Entry
+ * (RALUE).
+ * Bit 1 - Disable activity bit in Router Algorithmic LPM Unicast Host
+ * Entry (RAUHT).
+ * Bits 2:7 are reserved.
+ * Access: RW
+ *
+ * Note: Not supported by SwitchX, SwitchX-2 and Switch-IB.
+ */
+MLXSW_ITEM32(reg, rgcr, activity_dis, 0x20, 0, 8);
+
+static inline void mlxsw_reg_rgcr_pack(char *payload, bool ipv4_en)
+{
+	MLXSW_REG_ZERO(rgcr, payload);
+	mlxsw_reg_rgcr_ipv4_en_set(payload, ipv4_en);
+}
+
 /* MFCR - Management Fan Control Register
  * --------------------------------------
  * This register controls the settings of the Fan Speed PWM mechanism.
@@ -3924,6 +3998,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "HTGT";
 	case MLXSW_REG_HPKT_ID:
 		return "HPKT";
+	case MLXSW_REG_RGCR_ID:
+		return "RGCR";
 	case MLXSW_REG_MFCR_ID:
 		return "MFCR";
 	case MLXSW_REG_MFSC_ID:
-- 
2.5.5
