From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 9/9] mlxsw: reg: Fix missing op field fill-up
Date: Mon, 15 Aug 2016 16:37:53 +0200
Message-ID: <1471271873-4389-10-git-send-email-jiri@resnulli.us>
References: <1471271873-4389-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34539 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932236AbcHOOiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 10:38:08 -0400
Received: by mail-wm0-f66.google.com with SMTP id q128so11461573wma.1
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 07:38:08 -0700 (PDT)
In-Reply-To: <1471271873-4389-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ralue pack function needs to set op, otherwise it is 0 for add always.

Fixes: d5a1c749d22 ("mlxsw: reg: Add Router Algorithmic LPM Unicast Entry Register definition")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 7ca9201..14a5731 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4000,6 +4000,7 @@ static inline void mlxsw_reg_ralue_pack(char *payload,
 {
 	MLXSW_REG_ZERO(ralue, payload);
 	mlxsw_reg_ralue_protocol_set(payload, protocol);
+	mlxsw_reg_ralue_op_set(payload, op);
 	mlxsw_reg_ralue_virtual_router_set(payload, virtual_router);
 	mlxsw_reg_ralue_prefix_len_set(payload, prefix_len);
 	mlxsw_reg_ralue_entry_type_set(payload,
-- 
2.5.5
