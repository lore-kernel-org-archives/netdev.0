From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 16/17] mlxsw: spectrum_router: Abort on source-specific routes
Date: Wed, 19 Jul 2017 09:02:31 +0200
Message-ID: <20170719070232.28457-17-jiri@resnulli.us>
References: <20170719070232.28457-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33858 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753118AbdGSHC6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 03:02:58 -0400
Received: by mail-wm0-f67.google.com with SMTP id p204so2169654wmg.1
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 00:02:58 -0700 (PDT)
In-Reply-To: <20170719070232.28457-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Without resorting to ACLs, the device performs route lookup solely based
on the destination IP address.

In case source-specific routing is needed, an error is returned and the
abort mechanism is activated, thus allowing the kernel to take over
forwarding decisions.

Instead of aborting, we can trap specific destination prefixes where
source-specific routes are present, but this will result in a lot more
code that is unlikely to ever be used.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index c56c700..33cb6b6 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3429,6 +3429,9 @@ static int mlxsw_sp_router_fib6_add(struct mlxsw_sp *mlxsw_sp,
 	if (mlxsw_sp->router->aborted)
 		return 0;
 
+	if (rt->rt6i_src.plen)
+		return -EINVAL;
+
 	if (mlxsw_sp_fib6_rt_should_ignore(rt))
 		return 0;
 
-- 
2.9.3
