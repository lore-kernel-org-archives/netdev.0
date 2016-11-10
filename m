From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: spectrum_router: Add FIB abort warning
Date: Thu, 10 Nov 2016 12:10:29 +0100
Message-ID: <1478776229-4722-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34762 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754704AbcKJLKb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 06:10:31 -0500
Received: by mail-wm0-f65.google.com with SMTP id g23so2406144wme.1
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 03:10:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add a warning that the abort mechanism was triggered for device.
Also avoid going through the procedure if abort was already done.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 348c773..df31f38 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1877,6 +1877,9 @@ static void mlxsw_sp_router_fib4_abort(struct mlxsw_sp *mlxsw_sp)
 	int i;
 	int err;
 
+	if (mlxsw_sp->router.aborted)
+		return;
+	dev_warn(mlxsw_sp->bus_info->dev, "FIB abort triggered. Note that FIB entries are no longer being offloaded to this device.\n");
 	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_VRS); i++) {
 		vr = &mlxsw_sp->router.vrs[i];
 		if (!vr->used)
-- 
2.7.4
