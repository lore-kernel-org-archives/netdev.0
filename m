From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 23/26] mlxsw: reg: Add definition of LAG unicast record for SFN register
Date: Tue,  1 Dec 2015 14:49:01 +0100
Message-ID: <1448977744-17930-24-git-send-email-jiri@resnulli.us>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:34451 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756288AbbLANth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 08:49:37 -0500
Received: by wmvv187 with SMTP id v187so207550116wmv.1
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 05:49:36 -0800 (PST)
In-Reply-To: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

LAG-related records have specific format in SFN register.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 431b28e..4e4e4dc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -519,8 +519,12 @@ MLXSW_ITEM32_INDEXED(reg, sfn, rec_swid, MLXSW_REG_SFN_BASE_LEN, 24, 8,
 enum mlxsw_reg_sfn_rec_type {
 	/* MAC addresses learned on a regular port. */
 	MLXSW_REG_SFN_REC_TYPE_LEARNED_MAC = 0x5,
-	/* Aged-out MAC address on a regular port */
+	/* MAC addresses learned on a LAG port. */
+	MLXSW_REG_SFN_REC_TYPE_LEARNED_MAC_LAG = 0x6,
+	/* Aged-out MAC address on a regular port. */
 	MLXSW_REG_SFN_REC_TYPE_AGED_OUT_MAC = 0x7,
+	/* Aged-out MAC address on a LAG port. */
+	MLXSW_REG_SFN_REC_TYPE_AGED_OUT_MAC_LAG = 0x8,
 };
 
 /* reg_sfn_rec_type
@@ -568,6 +572,22 @@ static inline void mlxsw_reg_sfn_mac_unpack(char *payload, int rec_index,
 	*p_local_port = mlxsw_reg_sfn_mac_system_port_get(payload, rec_index);
 }
 
+/* reg_sfn_mac_lag_lag_id
+ * LAG ID (pointer into the LAG descriptor table).
+ * Access: RO
+ */
+MLXSW_ITEM32_INDEXED(reg, sfn, mac_lag_lag_id, MLXSW_REG_SFN_BASE_LEN, 0, 10,
+		     MLXSW_REG_SFN_REC_LEN, 0x0C, false);
+
+static inline void mlxsw_reg_sfn_mac_lag_unpack(char *payload, int rec_index,
+						char *mac, u16 *p_vid,
+						u16 *p_lag_id)
+{
+	mlxsw_reg_sfn_rec_mac_memcpy_from(payload, rec_index, mac);
+	*p_vid = mlxsw_reg_sfn_mac_fid_get(payload, rec_index);
+	*p_lag_id = mlxsw_reg_sfn_mac_lag_lag_id_get(payload, rec_index);
+}
+
 /* SPMS - Switch Port MSTP/RSTP State Register
  * -------------------------------------------
  * Configures the spanning tree state of a physical port.
-- 
1.9.3
