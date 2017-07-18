From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/22] mlxsw: reg: Update RAUHT register with IPv6 support
Date: Tue, 18 Jul 2017 10:10:14 +0200
Message-ID: <20170718081030.2781-7-jiri@resnulli.us>
References: <20170718081030.2781-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34244 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751441AbdGRIKp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 04:10:45 -0400
Received: by mail-wr0-f195.google.com with SMTP id w4so2852841wrb.1
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 01:10:45 -0700 (PDT)
In-Reply-To: <20170718081030.2781-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Update the register, so the IPv6 neighbours could be programmed to the
device's neighbour table.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index fe196fd..abfa631 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4960,6 +4960,7 @@ MLXSW_ITEM32(reg, rauht, rif, 0x00, 0, 16);
  * Access: Index
  */
 MLXSW_ITEM32(reg, rauht, dip4, 0x1C, 0x0, 32);
+MLXSW_ITEM_BUF(reg, rauht, dip6, 0x10, 16);
 
 enum mlxsw_reg_rauht_trap_action {
 	MLXSW_REG_RAUHT_TRAP_ACTION_NOP,
@@ -5024,6 +5025,15 @@ static inline void mlxsw_reg_rauht_pack4(char *payload,
 	mlxsw_reg_rauht_dip4_set(payload, dip);
 }
 
+static inline void mlxsw_reg_rauht_pack6(char *payload,
+					 enum mlxsw_reg_rauht_op op, u16 rif,
+					 const char *mac, const char *dip)
+{
+	mlxsw_reg_rauht_pack(payload, op, rif, mac);
+	mlxsw_reg_rauht_type_set(payload, MLXSW_REG_RAUHT_TYPE_IPV6);
+	mlxsw_reg_rauht_dip6_memcpy_to(payload, dip);
+}
+
 /* RALEU - Router Algorithmic LPM ECMP Update Register
  * ---------------------------------------------------
  * The register enables updating the ECMP section in the action for multiple
-- 
2.9.3
