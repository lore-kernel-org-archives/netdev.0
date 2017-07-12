From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/4] mlxsw: spectrum_router: Add missing rollback
Date: Wed, 12 Jul 2017 09:12:52 +0200
Message-ID: <20170712071255.1232-2-jiri@resnulli.us>
References: <20170712071255.1232-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33176 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756809AbdGLHNA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2017 03:13:00 -0400
Received: by mail-wr0-f196.google.com with SMTP id x23so3653498wrb.0
        for <netdev@vger.kernel.org>; Wed, 12 Jul 2017 00:12:59 -0700 (PDT)
In-Reply-To: <20170712071255.1232-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

With this patch the error path of mlxsw_sp_nexthop_init() is symmetric
with mlxsw_sp_nexthop_fini(). Noticed during code review.

Fixes: a8c970142798 ("mlxsw: spectrum_router: Refactor nexthop init routine")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 192cb93..129afc1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1790,6 +1790,7 @@ static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
 	return 0;
 
 err_nexthop_neigh_init:
+	mlxsw_sp_nexthop_rif_fini(nh);
 	mlxsw_sp_nexthop_remove(mlxsw_sp, nh);
 	return err;
 }
-- 
2.9.3
