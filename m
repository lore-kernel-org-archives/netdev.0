From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] drop_monitor: use setup_timer
Date: Sat, 11 Mar 2017 08:46:59 +0800
Message-ID: <03f9cf555a71fced65877c85e49fac7e880b338c.1489061285.git.geliangtang@gmail.com>
References: <3afa5498142ef68256023257dad37b9f8352e65e.1489060803.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34268 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933434AbdCKArd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 19:47:33 -0500
In-Reply-To: <3afa5498142ef68256023257dad37b9f8352e65e.1489060803.git.geliangtang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use setup_timer() instead of init_timer() to simplify the code.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 net/core/drop_monitor.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index fb55327..70ccda2 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -412,9 +412,8 @@ static int __init init_net_drop_monitor(void)
 	for_each_possible_cpu(cpu) {
 		data = &per_cpu(dm_cpu_data, cpu);
 		INIT_WORK(&data->dm_alert_work, send_dm_alert);
-		init_timer(&data->send_timer);
-		data->send_timer.data = (unsigned long)data;
-		data->send_timer.function = sched_send_work;
+		setup_timer(&data->send_timer, sched_send_work,
+			    (unsigned long)data);
 		spin_lock_init(&data->lock);
 		reset_per_cpu_data(data);
 	}
-- 
2.9.3
