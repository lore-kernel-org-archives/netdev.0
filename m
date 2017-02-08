From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/15] mlxsw: spectrum_router: Use nexthop's scope to set action type
Date: Wed,  8 Feb 2017 11:16:31 +0100
Message-ID: <1486549002-2056-5-git-send-email-jiri@resnulli.us>
References: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36310 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752848AbdBHKQt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 05:16:49 -0500
Received: by mail-wm0-f68.google.com with SMTP id r18so32479266wmd.3
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 02:16:48 -0800 (PST)
In-Reply-To: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We currently use the scope of the FIB info to distinguish between a
direct unicast route and a gatewayed one. However, the kernel is
perfectly happy to configure a route with scope UNIVERSE to a directly
connected network.

Instead, we can rely on the first nexthop's scope to check if the route
is gatewayed or not.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 3d540d9..cad7e9a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1721,7 +1721,7 @@ mlxsw_sp_router_fib4_entry_init(struct mlxsw_sp *mlxsw_sp,
 		return 0;
 	}
 
-	if (fi->fib_scope != RT_SCOPE_UNIVERSE) {
+	if (fi->fib_nh->nh_scope != RT_SCOPE_LINK) {
 		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_LOCAL;
 		fib_entry->rif = r->rif;
 	} else {
-- 
2.7.4
