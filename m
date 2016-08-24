From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/2] mlxsw: router: Enable neighbors to be created on stacked devices
Date: Wed, 24 Aug 2016 11:18:52 +0200
Message-ID: <1472030332-6208-3-git-send-email-jiri@resnulli.us>
References: <1472030332-6208-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33003 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750954AbcHXJf3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 05:35:29 -0400
Received: by mail-wm0-f66.google.com with SMTP id o80so1772714wme.0
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 02:34:30 -0700 (PDT)
In-Reply-To: <1472030332-6208-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Make the function mlxsw_router_neigh_construct search the rif according
to the neighbour dev other than the dev that was passed to the ndo, thus
allowing creating neigbhours upon stacked devices.

Fixes: 6cf3c971dc84 ("mlxsw: spectrum_router: Add private neigh table")
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 90bb93b..917ddd1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -657,7 +657,7 @@ int mlxsw_sp_router_neigh_construct(struct net_device *dev,
 		return 0;
 	}
 
-	r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
+	r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, n->dev);
 	if (WARN_ON(!r))
 		return -EINVAL;
 
-- 
2.5.5
