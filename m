From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/5] mlxsw: spectrum: Fix order of commands in port remove function
Date: Mon,  9 Jan 2017 11:25:47 +0100
Message-ID: <1483957548-3531-5-git-send-email-jiri@resnulli.us>
References: <1483957548-3531-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33936 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758630AbdAIK0B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 05:26:01 -0500
Received: by mail-wm0-f68.google.com with SMTP id c85so20823495wmi.1
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 02:26:00 -0800 (PST)
In-Reply-To: <1483957548-3531-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Fix the order of the free directives to match the port init function

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index f4b8ba2..1f4fdce 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2431,8 +2431,8 @@ static void __mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	mlxsw_sp_port_dcb_fini(mlxsw_sp_port);
 	mlxsw_sp_port_swid_set(mlxsw_sp_port, MLXSW_PORT_SWID_DISABLED_PORT);
 	mlxsw_sp_port_module_unmap(mlxsw_sp, mlxsw_sp_port->local_port);
-	free_percpu(mlxsw_sp_port->pcpu_stats);
 	kfree(mlxsw_sp_port->hw_stats.cache);
+	free_percpu(mlxsw_sp_port->pcpu_stats);
 	kfree(mlxsw_sp_port->untagged_vlans);
 	kfree(mlxsw_sp_port->active_vlans);
 	WARN_ON_ONCE(!list_empty(&mlxsw_sp_port->vports_list));
-- 
2.7.4
