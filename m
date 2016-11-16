From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: spectrum_router: Adjust placement of FIB abort warning
Date: Wed, 16 Nov 2016 09:51:58 +0100
Message-ID: <1479286318-6115-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:32867 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752307AbcKPIwB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 03:52:01 -0500
Received: by mail-wm0-f68.google.com with SMTP id u144so8715743wmu.0
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 00:52:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The recent merge commit bb598c1b8c9b ("Merge
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net") would cause
the FIB abort warning to fire whenever we flush the FIB tables - either
during module removal or actual abort.

Move it back to its rightful location in the FIB abort function.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 164bd30..683f045 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1872,9 +1872,6 @@ static void mlxsw_sp_router_fib_flush(struct mlxsw_sp *mlxsw_sp)
 	struct mlxsw_sp_vr *vr;
 	int i;
 
-	if (mlxsw_sp->router.aborted)
-		return;
-	dev_warn(mlxsw_sp->bus_info->dev, "FIB abort triggered. Note that FIB entries are no longer being offloaded to this device.\n");
 	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_VRS); i++) {
 		vr = &mlxsw_sp->router.vrs[i];
 
@@ -1899,6 +1896,9 @@ static void mlxsw_sp_router_fib4_abort(struct mlxsw_sp *mlxsw_sp)
 {
 	int err;
 
+	if (mlxsw_sp->router.aborted)
+		return;
+	dev_warn(mlxsw_sp->bus_info->dev, "FIB abort triggered. Note that FIB entries are no longer being offloaded to this device.\n");
 	mlxsw_sp_router_fib_flush(mlxsw_sp);
 	mlxsw_sp->router.aborted = true;
 	err = mlxsw_sp_router_set_abort_trap(mlxsw_sp);
-- 
2.7.4
