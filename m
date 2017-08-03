From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/21] rocker: Ignore address families other than IPv4
Date: Thu,  3 Aug 2017 13:28:13 +0200
Message-ID: <20170803112831.1831-4-jiri@resnulli.us>
References: <20170803112831.1831-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34561 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752113AbdHCL2k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 07:28:40 -0400
Received: by mail-wm0-f66.google.com with SMTP id x64so1829034wmg.1
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 04:28:40 -0700 (PDT)
In-Reply-To: <20170803112831.1831-1-jiri@resnulli.us>
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
