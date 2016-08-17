From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net v2 07/10] mlxsw: reg: Fix missing op field fill-up
Date: Wed, 17 Aug 2016 16:39:34 +0200
Message-ID: <1471444777-3412-8-git-send-email-jiri@resnulli.us>
References: <1471444777-3412-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	ilant@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33510 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752703AbcHQOju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 10:39:50 -0400
Received: by mail-wm0-f66.google.com with SMTP id o80so24865965wme.0
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 07:39:49 -0700 (PDT)
In-Reply-To: <1471444777-3412-1-git-send-email-jiri@resnulli.us>
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
index a1bd36c..1721098 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4010,6 +4010,7 @@ static inline void mlxsw_reg_ralue_pack(char *payload,
 {
 	MLXSW_REG_ZERO(ralue, payload);
 	mlxsw_reg_ralue_protocol_set(payload, protocol);
+	mlxsw_reg_ralue_op_set(payload, op);
 	mlxsw_reg_ralue_virtual_router_set(payload, virtual_router);
 	mlxsw_reg_ralue_prefix_len_set(payload, prefix_len);
 	mlxsw_reg_ralue_entry_type_set(payload,
-- 
2.5.5
