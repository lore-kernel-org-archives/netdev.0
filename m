From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 16/23] mlxsw: spectrum: Remove unused function argument
Date: Mon, 20 Jun 2016 23:04:14 +0200
Message-ID: <1466456661-5260-17-git-send-email-jiri@resnulli.us>
References: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f196.google.com ([209.85.217.196]:33408 "EHLO
	mail-lb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932711AbcFTVSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 17:18:53 -0400
Received: by mail-lb0-f196.google.com with SMTP id o4so248415lbp.0
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 14:18:53 -0700 (PDT)
In-Reply-To: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index ad8e447..4869392 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2872,7 +2872,6 @@ err_col_port_add:
 }
 
 static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
-					struct net_device *br_dev,
 					bool flush_fdb);
 
 static void mlxsw_sp_port_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port,
@@ -2903,7 +2902,7 @@ static void mlxsw_sp_port_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 			continue;
 
 		br_dev = mlxsw_sp_vport_br_get(mlxsw_sp_vport);
-		mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport, br_dev, false);
+		mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport, false);
 	}
 
 	if (mlxsw_sp_port->bridged) {
@@ -2995,7 +2994,7 @@ static void mlxsw_sp_port_vlan_unlink(struct mlxsw_sp_port *mlxsw_sp_port,
 		struct net_device *br_dev;
 
 		br_dev = mlxsw_sp_vport_br_get(mlxsw_sp_vport);
-		mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport, br_dev, true);
+		mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport, true);
 	}
 
 	mlxsw_sp_vport->dev = mlxsw_sp_port->dev;
@@ -3290,7 +3289,6 @@ err_vport_br_vfid_join:
 }
 
 static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
-					struct net_device *br_dev,
 					bool flush_fdb)
 {
 	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
@@ -3369,8 +3367,7 @@ static int mlxsw_sp_netdevice_vport_event(struct net_device *dev,
 			 */
 			if (!mlxsw_sp_vport)
 				return 0;
-			mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport, upper_dev,
-						    true);
+			mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport, true);
 		}
 	}
 
-- 
2.5.5
