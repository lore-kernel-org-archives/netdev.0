From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/7] mlxsw: spectrum: Make VLAN deletion function symmetric
Date: Wed, 24 Aug 2016 12:00:24 +0200
Message-ID: <1472032829-6322-3-git-send-email-jiri@resnulli.us>
References: <1472032829-6322-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:32880 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932424AbcHXKBV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 06:01:21 -0400
Received: by mail-wm0-f66.google.com with SMTP id o80so1870260wme.0
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 03:00:35 -0700 (PDT)
In-Reply-To: <1472032829-6322-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Commit 05978481e77e ("mlxsw: spectrum: Create PVID vPort before
registering netdevice") removed __mlxsw_sp_port_vlans_del() from the
init sequence of the driver, which forced it to be non-symmetric with
regards to __mlxsw_sp_port_vlans_add().

Make both functions symmetric as the constraint no longer exists.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 02de240..2f38310 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1008,14 +1008,6 @@ static int __mlxsw_sp_port_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (!mlxsw_sp_port->bridged)
 		return -EINVAL;
 
-	err = __mlxsw_sp_port_vlans_set(mlxsw_sp_port, vid_begin, vid_end,
-					false, false);
-	if (err) {
-		netdev_err(dev, "Unable to del VIDs %d-%d\n", vid_begin,
-			   vid_end);
-		return err;
-	}
-
 	pvid = mlxsw_sp_port->pvid;
 	if (pvid >= vid_begin && pvid <= vid_end) {
 		err = mlxsw_sp_port_pvid_set(mlxsw_sp_port, 0);
@@ -1025,6 +1017,14 @@ static int __mlxsw_sp_port_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port,
 		}
 	}
 
+	err = __mlxsw_sp_port_vlans_set(mlxsw_sp_port, vid_begin, vid_end,
+					false, false);
+	if (err) {
+		netdev_err(dev, "Unable to del VIDs %d-%d\n", vid_begin,
+			   vid_end);
+		return err;
+	}
+
 	mlxsw_sp_port_fid_leave(mlxsw_sp_port, vid_begin, vid_end);
 
 	/* Changing activity bits only if HW operation succeded */
-- 
2.5.5
