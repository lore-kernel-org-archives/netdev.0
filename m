From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 15/22] mlxsw: reg: Update RALUE register with IPv6 support
Date: Tue, 18 Jul 2017 10:10:23 +0200
Message-ID: <20170718081030.2781-16-jiri@resnulli.us>
References: <20170718081030.2781-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36588 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751543AbdGRIK5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 04:10:57 -0400
Received: by mail-wr0-f196.google.com with SMTP id y67so670540wrb.3
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 01:10:57 -0700 (PDT)
In-Reply-To: <20170718081030.2781-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Update the register so that IPv6 LPM entries could be programmed to the
device's table.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 0fc2263..c6c50894 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4724,6 +4724,7 @@ MLXSW_ITEM32(reg, ralue, prefix_len, 0x08, 0, 8);
  * Access: Index
  */
 MLXSW_ITEM32(reg, ralue, dip4, 0x18, 0, 32);
+MLXSW_ITEM_BUF(reg, ralue, dip6, 0x0C, 16);
 
 enum mlxsw_reg_ralue_entry_type {
 	MLXSW_REG_RALUE_ENTRY_TYPE_MARKER_ENTRY = 1,
@@ -4857,6 +4858,16 @@ static inline void mlxsw_reg_ralue_pack4(char *payload,
 	mlxsw_reg_ralue_dip4_set(payload, dip);
 }
 
+static inline void mlxsw_reg_ralue_pack6(char *payload,
+					 enum mlxsw_reg_ralxx_protocol protocol,
+					 enum mlxsw_reg_ralue_op op,
+					 u16 virtual_router, u8 prefix_len,
+					 const void *dip)
+{
+	mlxsw_reg_ralue_pack(payload, protocol, op, virtual_router, prefix_len);
+	mlxsw_reg_ralue_dip6_memcpy_to(payload, dip);
+}
+
 static inline void
 mlxsw_reg_ralue_act_remote_pack(char *payload,
 				enum mlxsw_reg_ralue_trap_action trap_action,
-- 
2.9.3
