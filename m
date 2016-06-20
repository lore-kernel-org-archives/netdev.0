From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/23] mlxsw: spectrum: Remove redundant function argument
Date: Mon, 20 Jun 2016 23:04:08 +0200
Message-ID: <1466456661-5260-11-git-send-email-jiri@resnulli.us>
References: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:34045 "EHLO
	mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932863AbcFTVS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 17:18:57 -0400
Received: by mail-lf0-f65.google.com with SMTP id l184so6836900lfl.1
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 14:18:56 -0700 (PDT)
In-Reply-To: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In all call sites 'only_uc' is set to false, so strip it.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c           | 12 +++++-------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h           |  2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c |  4 ++--
 3 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index b999802..90cf6c5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -791,7 +791,7 @@ int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 
 	if (!vfid->nr_vports) {
 		err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, vfid->vfid,
-					       true, false);
+					       true);
 		if (err) {
 			netdev_err(dev, "Failed to setup flooding for vFID=%d\n",
 				   vfid->vfid);
@@ -859,8 +859,7 @@ err_port_vid_to_fid_set:
 		mlxsw_sp_port_vlan_mode_trans(mlxsw_sp_port);
 err_port_vp_mode_trans:
 	if (!vfid->nr_vports)
-		mlxsw_sp_vport_flood_set(mlxsw_sp_vport, vfid->vfid, false,
-					 false);
+		mlxsw_sp_vport_flood_set(mlxsw_sp_vport, vfid->vfid, false);
 err_vport_flood_set:
 	mlxsw_sp_port_vport_destroy(mlxsw_sp_vport);
 err_port_vport_create:
@@ -3267,8 +3266,7 @@ static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
 		goto err_port_vid_learning_set;
 	}
 
-	err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, vfid->vfid, false,
-				       false);
+	err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, vfid->vfid, false);
 	if (err) {
 		netdev_err(dev, "Failed clear to clear flooding\n");
 		goto err_vport_flood_set;
@@ -3327,7 +3325,7 @@ static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 		}
 	}
 
-	err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, vfid->vfid, true, false);
+	err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, vfid->vfid, true);
 	if (err) {
 		netdev_err(dev, "Failed to setup flooding for vFID=%d\n",
 			   vfid->vfid);
@@ -3386,7 +3384,7 @@ err_port_vid_to_fid_validate:
 err_port_vid_to_fid_invalidate:
 	mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, false);
 err_port_vid_learning_set:
-	mlxsw_sp_vport_flood_set(mlxsw_sp_vport, vfid->vfid, false, false);
+	mlxsw_sp_vport_flood_set(mlxsw_sp_vport, vfid->vfid, false);
 err_port_flood_set:
 	if (!vfid->nr_vports)
 		mlxsw_sp_br_vfid_destroy(mlxsw_sp, vfid);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 5da98b4..58a2a5d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -367,7 +367,7 @@ int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 int mlxsw_sp_port_kill_vid(struct net_device *dev,
 			   __be16 __always_unused proto, u16 vid);
 int mlxsw_sp_vport_flood_set(struct mlxsw_sp_port *mlxsw_sp_vport, u16 vfid,
-			     bool set, bool only_uc);
+			     bool set);
 void mlxsw_sp_port_active_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port);
 int mlxsw_sp_port_pvid_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid);
 int mlxsw_sp_port_ets_set(struct mlxsw_sp_port *mlxsw_sp_port,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 3710f19..02c126c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -261,13 +261,13 @@ err_port_flood_set:
 }
 
 int mlxsw_sp_vport_flood_set(struct mlxsw_sp_port *mlxsw_sp_vport, u16 vfid,
-			     bool set, bool only_uc)
+			     bool set)
 {
 	/* In case of vFIDs, index into the flooding table is relative to
 	 * the start of the vFIDs range.
 	 */
 	return __mlxsw_sp_port_flood_set(mlxsw_sp_vport, vfid, vfid, set,
-					 only_uc);
+					 false);
 }
 
 static int mlxsw_sp_port_attr_br_flags_set(struct mlxsw_sp_port *mlxsw_sp_port,
-- 
2.5.5
