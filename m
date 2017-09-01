From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] mlxsw: spectrum_router: Set abort trap in all virtual routers
Date: Fri,  1 Sep 2017 10:58:56 +0200
Message-ID: <20170901085856.2286-3-jiri@resnulli.us>
References: <20170901085856.2286-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36193 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751589AbdIAI7C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 04:59:02 -0400
Received: by mail-wr0-f195.google.com with SMTP id 40so981575wrv.3
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 01:59:01 -0700 (PDT)
In-Reply-To: <20170901085856.2286-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When the abort mechanism is invoked a default route directing packets to
the CPU is programmed in all the virtual routers currently in use. This
can result in packet loss in case a new VRF is configured.

Upon abort, program the default route in all virtual routers, whether
they are in use or not.

The patch is directed at net-next since post-abort fixes aren't critical
and packet loss due to a missing default route will be insignificant
compared to packet loss caused by the CPU port policer.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 00e3aec..de15eac 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3993,9 +3993,6 @@ static int __mlxsw_sp_router_set_abort_trap(struct mlxsw_sp *mlxsw_sp,
 		char raltb_pl[MLXSW_REG_RALTB_LEN];
 		char ralue_pl[MLXSW_REG_RALUE_LEN];
 
-		if (!mlxsw_sp_vr_is_used(vr))
-			continue;
-
 		mlxsw_reg_raltb_pack(raltb_pl, vr->id, proto, tree_id);
 		err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(raltb),
 				      raltb_pl);
-- 
2.9.3
