From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/17] rocker: Ignore address families other than IPv4
Date: Wed, 19 Jul 2017 09:02:18 +0200
Message-ID: <20170719070232.28457-4-jiri@resnulli.us>
References: <20170719070232.28457-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35926 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752288AbdGSHCk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 03:02:40 -0400
Received: by mail-wm0-f67.google.com with SMTP id 15so2151176wmm.3
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 00:02:39 -0700 (PDT)
In-Reply-To: <20170719070232.28457-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

As in previous patch, ignore IPv6 notifications since the driver doesn't
support these.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index ef38c1a..fc8f8bd 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -2192,6 +2192,10 @@ static int rocker_router_fib_event(struct notifier_block *nb,
 {
 	struct rocker *rocker = container_of(nb, struct rocker, fib_nb);
 	struct rocker_fib_event_work *fib_work;
+	struct fib_notifier_info *info = ptr;
+
+	if (info->family != AF_INET)
+		return NOTIFY_DONE;
 
 	fib_work = kzalloc(sizeof(*fib_work), GFP_ATOMIC);
 	if (WARN_ON(!fib_work))
-- 
2.9.3
