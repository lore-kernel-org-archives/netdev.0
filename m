From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: spectrum_router: Use correct config option
Date: Tue, 15 Aug 2017 09:10:33 +0200
Message-ID: <20170815071033.1420-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33987 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753233AbdHOHKg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 03:10:36 -0400
Received: by mail-wm0-f67.google.com with SMTP id x64so518200wmg.1
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 00:10:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

I made an embarrassing mistake and used 'IPV6' instead of 'CONFIG_IPV6'
around the function that updates the kernel about IPv6 neighbours
activity. This can be a problem if the kernel has more neighbours than a
certain threshold and it starts deleting those that are supposedly
inactive.

Fixes: b5f3e0d43012 ("mlxsw: spectrum_router: Fix build when IPv6 isn't enabled")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 4895d5b..a0a9728 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1042,7 +1042,7 @@ static void mlxsw_sp_router_neigh_ent_ipv4_process(struct mlxsw_sp *mlxsw_sp,
 	neigh_release(n);
 }
 
-#if IS_ENABLED(IPV6)
+#if IS_ENABLED(CONFIG_IPV6)
 static void mlxsw_sp_router_neigh_ent_ipv6_process(struct mlxsw_sp *mlxsw_sp,
 						   char *rauhtd_pl,
 						   int rec_index)
-- 
2.9.3
