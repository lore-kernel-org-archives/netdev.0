From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/19] mlxsw: core: Introduce generic macro for event
Date: Fri, 25 Nov 2016 10:33:34 +0100
Message-ID: <1480066427-3961-7-git-send-email-jiri@resnulli.us>
References: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33663 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752253AbcKYJem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 04:34:42 -0500
Received: by mail-wm0-f66.google.com with SMTP id u144so7192160wmu.0
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 01:33:56 -0800 (PST)
In-Reply-To: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Create a macro for creating the generic listener struct for events,
similar to the one for rx traps.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 5f6fed1..852218e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -115,6 +115,18 @@ struct mlxsw_listener {
 		.is_event = false,					\
 	}
 
+#define MLXSW_EVENTL(_func, _trap_id)				\
+	{							\
+		.trap_id = MLXSW_TRAP_ID_##_trap_id,		\
+		.u.event_listener =				\
+		{						\
+			.func = _func,				\
+			.trap_id = MLXSW_TRAP_ID_##_trap_id,	\
+		},						\
+		.action = MLXSW_REG_HPKT_ACTION_TRAP_TO_CPU,	\
+		.is_event = true,				\
+	}
+
 int mlxsw_core_rx_listener_register(struct mlxsw_core *mlxsw_core,
 				    const struct mlxsw_rx_listener *rxl,
 				    void *priv);
-- 
2.7.4
