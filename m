From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/23] mlxsw: spectrum: Use WARN_ON() return value
Date: Mon, 20 Jun 2016 23:04:03 +0200
Message-ID: <1466456661-5260-6-git-send-email-jiri@resnulli.us>
References: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:34799 "EHLO
	mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753156AbcFTVWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 17:22:06 -0400
Received: by mail-lf0-f67.google.com with SMTP id l184so6843862lfl.1
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 14:20:35 -0700 (PDT)
In-Reply-To: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Instead of checking for a condition and then issue the warning, just do
it in one go and simplify the code.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index e55c685..f297b10 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2980,10 +2980,8 @@ static int mlxsw_sp_port_vlan_link(struct mlxsw_sp_port *mlxsw_sp_port,
 	u16 vid = vlan_dev_vlan_id(vlan_dev);
 
 	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, vid);
-	if (!mlxsw_sp_vport) {
-		WARN_ON(!mlxsw_sp_vport);
+	if (WARN_ON(!mlxsw_sp_vport))
 		return -EINVAL;
-	}
 
 	mlxsw_sp_vport->dev = vlan_dev;
 
@@ -2997,10 +2995,8 @@ static int mlxsw_sp_port_vlan_unlink(struct mlxsw_sp_port *mlxsw_sp_port,
 	u16 vid = vlan_dev_vlan_id(vlan_dev);
 
 	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, vid);
-	if (!mlxsw_sp_vport) {
-		WARN_ON(!mlxsw_sp_vport);
+	if (WARN_ON(!mlxsw_sp_vport))
 		return -EINVAL;
-	}
 
 	/* When removing a VLAN device while still bridged we should first
 	 * remove it from the bridge, as we receive the bridge's notification
@@ -3236,10 +3232,8 @@ static int mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
 	int err;
 
 	vfid = mlxsw_sp_br_vfid_find(mlxsw_sp, br_dev);
-	if (!vfid) {
-		WARN_ON(!vfid);
+	if (WARN_ON(!vfid))
 		return -EINVAL;
-	}
 
 	/* We need a vFID to go back to after leaving the bridge's vFID. */
 	new_vfid = mlxsw_sp_vfid_find(mlxsw_sp, vid);
@@ -3454,10 +3448,8 @@ static int mlxsw_sp_netdevice_vport_event(struct net_device *dev,
 	case NETDEV_CHANGEUPPER:
 		upper_dev = info->upper_dev;
 		if (info->linking) {
-			if (!mlxsw_sp_vport) {
-				WARN_ON(!mlxsw_sp_vport);
+			if (WARN_ON(!mlxsw_sp_vport))
 				return -EINVAL;
-			}
 			err = mlxsw_sp_vport_bridge_join(mlxsw_sp_vport,
 							 upper_dev);
 		} else {
-- 
2.5.5
