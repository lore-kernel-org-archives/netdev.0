From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/4] mlxsw: core: Change order of operations in removal path
Date: Mon, 28 Nov 2016 18:01:26 +0100
Message-ID: <1480352486-18518-5-git-send-email-jiri@resnulli.us>
References: <1480352486-18518-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33971 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933455AbcK1RBe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 12:01:34 -0500
Received: by mail-wm0-f65.google.com with SMTP id g23so20099072wme.1
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 09:01:33 -0800 (PST)
In-Reply-To: <1480352486-18518-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We call bus->init() before allocating 'lag.mapping'. Change the order of
operations in removal path to reflect that.

This makes the error path of mlxsw_core_bus_device_register() symmetric
with mlxsw_core_bus_device_unregister().

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index 7a0ad39..4dc028b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -1188,8 +1188,8 @@ void mlxsw_core_bus_device_unregister(struct mlxsw_core *mlxsw_core)
 	mlxsw_thermal_fini(mlxsw_core->thermal);
 	devlink_unregister(devlink);
 	mlxsw_emad_fini(mlxsw_core);
-	mlxsw_core->bus->fini(mlxsw_core->bus_priv);
 	kfree(mlxsw_core->lag.mapping);
+	mlxsw_core->bus->fini(mlxsw_core->bus_priv);
 	free_percpu(mlxsw_core->pcpu_stats);
 	devlink_free(devlink);
 	mlxsw_core_driver_put(device_kind);
-- 
2.7.4
