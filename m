From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/19] mlxsw: core: Expose generic macros for rx trap
Date: Fri, 25 Nov 2016 10:33:31 +0100
Message-ID: <1480066427-3961-4-git-send-email-jiri@resnulli.us>
References: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:33400 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751691AbcKYJem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 04:34:42 -0500
Received: by mail-wj0-f195.google.com with SMTP id kp2so4928149wjc.0
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 01:33:53 -0800 (PST)
In-Reply-To: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

In Spectrum, there is a macro to arrange the traps list.
This macro is useful for everyone who is using rx traps.
Create a similar macro in core.h for creating the generic listener struct
for rx traps.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.h | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 66d97c4..5f6fed1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -101,6 +101,20 @@ struct mlxsw_listener {
 	bool is_event;
 };
 
+#define MLXSW_RXL(_func, _trap_id, _action, _unreg_action)		\
+	{								\
+		.trap_id = MLXSW_TRAP_ID_##_trap_id,			\
+		.u.rx_listener =					\
+		{							\
+			.func = _func,					\
+			.local_port = MLXSW_PORT_DONT_CARE,		\
+			.trap_id = MLXSW_TRAP_ID_##_trap_id,		\
+		},							\
+		.action = MLXSW_REG_HPKT_ACTION_##_action,		\
+		.unreg_action = MLXSW_REG_HPKT_ACTION_##_unreg_action,	\
+		.is_event = false,					\
+	}
+
 int mlxsw_core_rx_listener_register(struct mlxsw_core *mlxsw_core,
 				    const struct mlxsw_rx_listener *rxl,
 				    void *priv);
-- 
2.7.4
