From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 21/21] mlxsw: spectrum_router: Don't ignore IPv6 notifications
Date: Thu,  3 Aug 2017 13:28:31 +0200
Message-ID: <20170803112831.1831-22-jiri@resnulli.us>
References: <20170803112831.1831-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33264 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752233AbdHCL3N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 07:29:13 -0400
Received: by mail-wr0-f194.google.com with SMTP id y43so804681wrd.0
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 04:29:12 -0700 (PDT)
In-Reply-To: <20170803112831.1831-1-jiri@resnulli.us>
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
index 45cf32c..93b6da8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3912,7 +3912,7 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
 	struct fib_notifier_info *info = ptr;
 	struct mlxsw_sp_router *router;
 
-	if (!net_eq(info->net, &init_net) || info->family != AF_INET)
+	if (!net_eq(info->net, &init_net))
 		return NOTIFY_DONE;
 
 	fib_work = kzalloc(sizeof(*fib_work), GFP_ATOMIC);
-- 
2.9.3
