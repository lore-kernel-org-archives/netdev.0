From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/17] mlxsw: spectrum_router: Ignore address families other than IPv4
Date: Wed, 19 Jul 2017 09:02:17 +0200
Message-ID: <20170719070232.28457-3-jiri@resnulli.us>
References: <20170719070232.28457-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35331 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751390AbdGSHCi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 03:02:38 -0400
Received: by mail-wr0-f195.google.com with SMTP id c24so4053213wra.2
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 00:02:38 -0700 (PDT)
In-Reply-To: <20170719070232.28457-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We're about to add IPv6 notifications in the FIB notification chain, but
the driver currently doesn't support these, so ignore them.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 6069681..7965a53 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -43,6 +43,7 @@
 #include <linux/inetdevice.h>
 #include <linux/netdevice.h>
 #include <linux/if_bridge.h>
+#include <linux/socket.h>
 #include <net/netevent.h>
 #include <net/neighbour.h>
 #include <net/arp.h>
@@ -3034,7 +3035,7 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
 	struct fib_notifier_info *info = ptr;
 	struct mlxsw_sp_router *router;
 
-	if (!net_eq(info->net, &init_net))
+	if (!net_eq(info->net, &init_net) || info->family != AF_INET)
 		return NOTIFY_DONE;
 
 	fib_work = kzalloc(sizeof(*fib_work), GFP_ATOMIC);
-- 
2.9.3
