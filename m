From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/2] mlxsw: spectrum: Always decrement bridge's ref count
Date: Mon,  7 Mar 2016 09:24:51 +0100
Message-ID: <1457339092-2878-2-git-send-email-jiri@resnulli.us>
References: <1457339092-2878-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35837 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752196AbcCGIY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 03:24:57 -0500
Received: by mail-wm0-f52.google.com with SMTP id l68so74084129wml.0
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 00:24:57 -0800 (PST)
In-Reply-To: <1457339092-2878-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Since we only support one VLAN filtering bridge we need to associate a
reference count with it, so that when the last port netdev leaves it, we
would know that a different bridge can be offloaded to hardware.

When a LAG device is memeber in a bridge and port netdevs are leaving
the LAG, we should always decrement the bridge's reference count, as it's
incremented for any port in the LAG.

Fixes: 4dc236c31733 ("mlxsw: spectrum: Handle port leaving LAG while bridged")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 09ce451..a94daa8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2358,9 +2358,7 @@ static int mlxsw_sp_port_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (mlxsw_sp_port->bridged) {
 		mlxsw_sp_port_active_vlans_del(mlxsw_sp_port);
 		mlxsw_sp_port_bridge_leave(mlxsw_sp_port, false);
-
-		if (lag->ref_count == 1)
-			mlxsw_sp_master_bridge_dec(mlxsw_sp, NULL);
+		mlxsw_sp_master_bridge_dec(mlxsw_sp, NULL);
 	}
 
 	if (lag->ref_count == 1) {
-- 
2.5.0
