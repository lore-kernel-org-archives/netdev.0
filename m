From: Ben Greear <greearb@candelatech.com>
Subject: [net-next] net:  Provide details on watchdog timeout.
Date: Mon,  9 Aug 2010 12:16:41 -0700
Message-ID: <1281381401-5554-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33188 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754386Ab0HITQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 15:16:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This also makes it printed under net_ratelimit instead
of WARN_ON_ONCE.  The backtrace never helped me much.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 2aeb3a4... b52c450... M	net/sched/sch_generic.c
 net/sched/sch_generic.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 2aeb3a4..b52c450 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -253,9 +253,15 @@ static void dev_watchdog(unsigned long arg)
 			}
 
 			if (some_queue_timedout) {
-				char drivername[64];
-				WARN_ONCE(1, KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit queue %u timed out\n",
-				       dev->name, netdev_drivername(dev, drivername, 64), i);
+				if (net_ratelimit()) {
+					char drivername[64];
+					printk(KERN_INFO "NETDEV WATCHDOG: %s (%s): "
+					       "transmit queue %u timed out"
+					       " trans-start: %lu  jiffies: %lu\n",
+					       dev->name,
+					       netdev_drivername(dev, drivername, 64),
+					       i, trans_start, jiffies);
+				}
 				dev->netdev_ops->ndo_tx_timeout(dev);
 			}
 			if (!mod_timer(&dev->watchdog_timer,
-- 
1.6.2.5

