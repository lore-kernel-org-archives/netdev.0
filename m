From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] mlxsw: spectrum: Mark split ports as such
Date: Fri, 16 Dec 2016 19:29:03 +0100
Message-ID: <1481912943-2864-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        tamirw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33569 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758282AbcLPS3G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 13:29:06 -0500
Received: by mail-wm0-f68.google.com with SMTP id u144so7030479wmu.0
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2016 10:29:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When a port is split we should mark it as such, as otherwise the split
ports aren't renamed correctly (e.g. sw1p3 -> sw1p3s1) and the unsplit
operation fails:

$ devlink port split sw1p3 count 4
$ devlink port unsplit eth0
devlink answers: Invalid argument
[  598.565307] mlxsw_spectrum 0000:03:00.0 eth0: Port wasn't split

Fixes: 67963a33b4fd ("mlxsw: Make devlink port instances independent of spectrum/switchx2 port instances")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Reported-by: Tamir Winetroub <tamirw@mellanox.com>
Reviewed-by: Elad Raz <eladr@mellanox.com>
Tested-by: Tamir Winetroub <tamirw@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index fece974..d768c7b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2404,7 +2404,7 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 			local_port);
 		return err;
 	}
-	err = __mlxsw_sp_port_create(mlxsw_sp, local_port, false,
+	err = __mlxsw_sp_port_create(mlxsw_sp, local_port, split,
 				     module, width, lane);
 	if (err)
 		goto err_port_create;
-- 
2.7.4
