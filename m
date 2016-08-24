From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/7] mlxsw: spectrum: Remove unnecessary check in FDB processing
Date: Wed, 24 Aug 2016 12:00:28 +0200
Message-ID: <1472032829-6322-7-git-send-email-jiri@resnulli.us>
References: <1472032829-6322-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34592 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932488AbcHXKBV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 06:01:21 -0400
Received: by mail-wm0-f68.google.com with SMTP id q128so1862213wma.1
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 03:00:39 -0700 (PDT)
In-Reply-To: <1472032829-6322-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We now offload the learning configuration to the device and don't rely
on the driver to decide whether to learn the FDB record, so remove the
check.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index e0a7232..0c3fbbc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1430,8 +1430,6 @@ static void mlxsw_sp_fdb_notify_mac_process(struct mlxsw_sp *mlxsw_sp,
 		vid = fid;
 	}
 
-	adding = adding && mlxsw_sp_port->learning;
-
 do_fdb_op:
 	err = mlxsw_sp_port_fdb_uc_op(mlxsw_sp, local_port, mac, fid,
 				      adding, true);
@@ -1493,8 +1491,6 @@ static void mlxsw_sp_fdb_notify_mac_lag_process(struct mlxsw_sp *mlxsw_sp,
 		vid = fid;
 	}
 
-	adding = adding && mlxsw_sp_port->learning;
-
 do_fdb_op:
 	err = mlxsw_sp_port_fdb_uc_lag_op(mlxsw_sp, lag_id, mac, fid, lag_vid,
 					  adding, true);
-- 
2.5.5
