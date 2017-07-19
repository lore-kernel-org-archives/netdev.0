From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 17/17] mlxsw: spectrum_router: Don't ignore IPv6 notifications
Date: Wed, 19 Jul 2017 09:02:32 +0200
Message-ID: <20170719070232.28457-18-jiri@resnulli.us>
References: <20170719070232.28457-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35413 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753120AbdGSHDA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 03:03:00 -0400
Received: by mail-wr0-f196.google.com with SMTP id c24so4053812wra.2
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 00:02:59 -0700 (PDT)
In-Reply-To: <20170719070232.28457-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We now have all the necessary IPv6 infrastructure in place, so stop
ignoring these notifications.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 33cb6b6..dc9a032 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3813,7 +3813,7 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
 	struct fib_notifier_info *info = ptr;
 	struct mlxsw_sp_router *router;
 
-	if (!net_eq(info->net, &init_net) || info->family != AF_INET)
+	if (!net_eq(info->net, &init_net))
 		return NOTIFY_DONE;
 
 	fib_work = kzalloc(sizeof(*fib_work), GFP_ATOMIC);
-- 
2.9.3
