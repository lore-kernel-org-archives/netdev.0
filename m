From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: spectrum_router: Don't ignore IPv6 notifications
Date: Fri, 21 Jul 2017 18:05:23 +0200
Message-ID: <20170721160523.23228-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36334 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751302AbdGUQF0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 12:05:26 -0400
Received: by mail-wr0-f195.google.com with SMTP id y67so11807979wrb.3
        for <netdev@vger.kernel.org>; Fri, 21 Jul 2017 09:05:25 -0700 (PDT)
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
index 9adb239..fa15f17 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3804,7 +3804,7 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
 	struct fib_notifier_info *info = ptr;
 	struct mlxsw_sp_router *router;
 
-	if (!net_eq(info->net, &init_net) || info->family != AF_INET)
+	if (!net_eq(info->net, &init_net))
 		return NOTIFY_DONE;
 
 	fib_work = kzalloc(sizeof(*fib_work), GFP_ATOMIC);
-- 
2.9.3
