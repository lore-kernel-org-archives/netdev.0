From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 23/23] mlxsw: spectrum: Add debug prints
Date: Mon, 20 Jun 2016 23:04:21 +0200
Message-ID: <1466456661-5260-24-git-send-email-jiri@resnulli.us>
References: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f193.google.com ([209.85.217.193]:33819 "EHLO
	mail-lb0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622AbcFTVSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 17:18:18 -0400
Received: by mail-lb0-f193.google.com with SMTP id w10so247795lbo.1
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 14:18:16 -0700 (PDT)
In-Reply-To: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

For debug purposes, it's useful to know the order in which the driver
responds to changes in the topology of its upper devices.

Add debug prints to signal these events.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c           | 10 ++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c |  4 ++++
 2 files changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 9f48ec5..d23948b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2589,6 +2589,9 @@ mlxsw_sp_port_fdb_flush_by_port_fid(const struct mlxsw_sp_port *mlxsw_sp_port,
 	mlxsw_reg_sfdf_port_fid_system_port_set(sfdf_pl,
 						mlxsw_sp_port->local_port);
 
+	netdev_dbg(mlxsw_sp_port->dev, "FDB flushed using Port=%d, FID=%d\n",
+		   mlxsw_sp_port->local_port, fid);
+
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfdf), sfdf_pl);
 }
 
@@ -2603,6 +2606,9 @@ mlxsw_sp_port_fdb_flush_by_lag_id_fid(const struct mlxsw_sp_port *mlxsw_sp_port,
 	mlxsw_reg_sfdf_fid_set(sfdf_pl, fid);
 	mlxsw_reg_sfdf_lag_fid_lag_id_set(sfdf_pl, mlxsw_sp_port->lag_id);
 
+	netdev_dbg(mlxsw_sp_port->dev, "FDB flushed using LAG ID=%d, FID=%d\n",
+		   mlxsw_sp_port->lag_id, fid);
+
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfdf), sfdf_pl);
 }
 
@@ -3174,6 +3180,8 @@ static int mlxsw_sp_vport_br_vfid_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 	mlxsw_sp_vport_fid_set(mlxsw_sp_vport, f);
 	f->ref_count++;
 
+	netdev_dbg(mlxsw_sp_vport->dev, "Joined FID=%d\n", f->fid);
+
 	return 0;
 
 err_vport_fid_map:
@@ -3188,6 +3196,8 @@ static void mlxsw_sp_vport_br_vfid_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
 {
 	struct mlxsw_sp_fid *f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
 
+	netdev_dbg(mlxsw_sp_vport->dev, "Left FID=%d\n", f->fid);
+
 	mlxsw_sp_vport_fid_map(mlxsw_sp_vport, f->fid, false);
 
 	mlxsw_sp_vport_flood_set(mlxsw_sp_vport, f->fid, false);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 7c2b0f8..a0c7376 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -488,6 +488,8 @@ static int __mlxsw_sp_port_fid_join(struct mlxsw_sp_port *mlxsw_sp_port,
 
 	f->ref_count++;
 
+	netdev_dbg(mlxsw_sp_port->dev, "Joined FID=%d\n", fid);
+
 	return 0;
 }
 
@@ -500,6 +502,8 @@ static void __mlxsw_sp_port_fid_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (WARN_ON(!f))
 		return;
 
+	netdev_dbg(mlxsw_sp_port->dev, "Left FID=%d\n", fid);
+
 	mlxsw_sp_port_fdb_flush(mlxsw_sp_port, fid);
 
 	if (--f->ref_count == 0)
-- 
2.5.5
