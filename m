From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 14/16] mlxsw: reg: Add Switch Filtering Database Aging Time register definition
Date: Fri, 16 Oct 2015 14:01:35 +0200
Message-ID: <1444996897-2708-15-git-send-email-jiri@resnulli.us>
References: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org, tgraf@suug.ch, jhs@mojatatu.com,
	sagir@mellanox.com, mattyk@mellanox.com, aviadr@mellanox.com
To: netdev@vger.kernel.org, ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:38040 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753935AbbJPMB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 08:01:58 -0400
Received: by wicll6 with SMTP id ll6so7355029wic.1
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 05:01:57 -0700 (PDT)
In-Reply-To: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add SFDAT which is used to control switch ageing time.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 37 +++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 8e1888b..d1c8eff 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -157,6 +157,41 @@ static inline void mlxsw_reg_sspr_pack(char *payload, u8 local_port)
 	mlxsw_reg_sspr_system_port_set(payload, local_port);
 }
 
+/* SFDAT - Switch Filtering Database Aging Time
+ * --------------------------------------------
+ * Controls the Switch aging time. Aging time is able to be set per Switch
+ * Partition.
+ */
+#define MLXSW_REG_SFDAT_ID 0x2009
+#define MLXSW_REG_SFDAT_LEN 0x8
+
+static const struct mlxsw_reg_info mlxsw_reg_sfdat = {
+	.id = MLXSW_REG_SFDAT_ID,
+	.len = MLXSW_REG_SFDAT_LEN,
+};
+
+/* reg_sfdat_swid
+ * Switch partition ID.
+ * Access: Index
+ */
+MLXSW_ITEM32(reg, sfdat, swid, 0x00, 24, 8);
+
+/* reg_sfdat_age_time
+ * Aging time in seconds
+ * Min - 10 seconds
+ * Max - 1,000,000 seconds
+ * Default is 300 seconds.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, sfdat, age_time, 0x04, 0, 20);
+
+static inline void mlxsw_reg_sfdat_pack(char *payload, u32 age_time)
+{
+	MLXSW_REG_ZERO(sfdat, payload);
+	mlxsw_reg_sfdat_swid_set(payload, 0);
+	mlxsw_reg_sfdat_age_time_set(payload, age_time);
+}
+
 /* SFD - Switch Filtering Database
  * -------------------------------
  * The following register defines the access to the filtering database.
@@ -2259,6 +2294,8 @@ static inline const char *mlxsw_reg_id_str(u16 reg_id)
 		return "SPAD";
 	case MLXSW_REG_SSPR_ID:
 		return "SSPR";
+	case MLXSW_REG_SFDAT_ID:
+		return "SFDAT";
 	case MLXSW_REG_SFD_ID:
 		return "SFD";
 	case MLXSW_REG_SFN_ID:
-- 
1.9.3
