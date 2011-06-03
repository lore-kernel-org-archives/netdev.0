From: Connor Hansen <cmdkhh@gmail.com>
Subject: [PATCH] sch_generic unused variable warning
Date: Fri,  3 Jun 2011 16:18:26 -0700
Message-ID: <1307143106-14523-1-git-send-email-cmdkhh@gmail.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Connor Hansen <cmdkhh@gmail.com>
To: hadi@cyberus.ca
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

during randconfig testing net/sched/sch_generic produced
net/sched/sch_generic.c: In function dev_watchdog
net/sched/sch_generic.c:254:10: warning: unused variable drivername

drivername is only used in the scope of the WARN_ONCE

Signed-off-by: Connor Hansen <cmdkhh@gmail.com>
---
 net/sched/sch_generic.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index b1721d7..7380da2 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -251,9 +251,8 @@ static void dev_watchdog(unsigned long arg)
 			}
 
 			if (some_queue_timedout) {
-				char drivername[64];
 				WARN_ONCE(1, KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit queue %u timed out\n",
-				       dev->name, netdev_drivername(dev, drivername, 64), i);
+				       dev->name, netdev_drivername(dev, char drivername[64], 64), i);
 				dev->netdev_ops->ndo_tx_timeout(dev);
 			}
 			if (!mod_timer(&dev->watchdog_timer,
-- 
1.7.4.4
