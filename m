From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/23] mlxsw: spectrum: Remove unnecessary function argument
Date: Mon, 20 Jun 2016 23:04:05 +0200
Message-ID: <1466456661-5260-8-git-send-email-jiri@resnulli.us>
References: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f193.google.com ([209.85.217.193]:36150 "EHLO
	mail-lb0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752697AbcFTVTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 17:19:51 -0400
Received: by mail-lb0-f193.google.com with SMTP id z2so251489lbu.3
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 14:19:51 -0700 (PDT)
In-Reply-To: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The argument 'br_dev' is never used, so remove it.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 3500a72..cd85316 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2708,8 +2708,7 @@ static void mlxsw_sp_master_bridge_inc(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_sp->master_bridge.ref_count++;
 }
 
-static void mlxsw_sp_master_bridge_dec(struct mlxsw_sp *mlxsw_sp,
-				       struct net_device *br_dev)
+static void mlxsw_sp_master_bridge_dec(struct mlxsw_sp *mlxsw_sp)
 {
 	if (--mlxsw_sp->master_bridge.ref_count == 0)
 		mlxsw_sp->master_bridge.dev = NULL;
@@ -2911,7 +2910,7 @@ static void mlxsw_sp_port_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (mlxsw_sp_port->bridged) {
 		mlxsw_sp_port_active_vlans_del(mlxsw_sp_port);
 		mlxsw_sp_port_bridge_leave(mlxsw_sp_port, false);
-		mlxsw_sp_master_bridge_dec(mlxsw_sp, NULL);
+		mlxsw_sp_master_bridge_dec(mlxsw_sp);
 	}
 
 	if (lag->ref_count == 1) {
@@ -3055,7 +3054,7 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 				mlxsw_sp_master_bridge_inc(mlxsw_sp, upper_dev);
 			} else {
 				mlxsw_sp_port_bridge_leave(mlxsw_sp_port, true);
-				mlxsw_sp_master_bridge_dec(mlxsw_sp, upper_dev);
+				mlxsw_sp_master_bridge_dec(mlxsw_sp);
 			}
 		} else if (netif_is_lag_master(upper_dev)) {
 			if (info->linking)
-- 
2.5.5
