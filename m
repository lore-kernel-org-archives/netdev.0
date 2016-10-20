From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/4] mlxsw: spectrum_router: Use correct tree index for binding
Date: Thu, 20 Oct 2016 16:05:42 +0200
Message-ID: <1476972345-31568-2-git-send-email-jiri@resnulli.us>
References: <1476972345-31568-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:36566 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753299AbcJTOFu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 10:05:50 -0400
Received: by mail-lf0-f66.google.com with SMTP id b75so431660lfg.3
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 07:05:49 -0700 (PDT)
In-Reply-To: <1476972345-31568-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

By a mistake, there is tree index 0 passed to RALTB. Should be
MLXSW_SP_LPM_TREE_MIN.

Fixes: b45f64d16d45 ("mlxsw: spectrum_router: Use FIB notifications instead of switchdev calls")
Reported-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 78fc557d..1b3a2cb 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1862,7 +1862,8 @@ static int mlxsw_sp_router_set_abort_trap(struct mlxsw_sp *mlxsw_sp)
 	if (err)
 		return err;
 
-	mlxsw_reg_raltb_pack(raltb_pl, 0, MLXSW_REG_RALXX_PROTOCOL_IPV4, 0);
+	mlxsw_reg_raltb_pack(raltb_pl, 0, MLXSW_REG_RALXX_PROTOCOL_IPV4,
+			     MLXSW_SP_LPM_TREE_MIN);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(raltb), raltb_pl);
 	if (err)
 		return err;
-- 
2.5.5
