From: Vinay K Nallamothu <vinay-rc@naturesoft.net>
Subject: [PATCH 2.{4,5}.x] mod_timer cleanups for sch_cbq.c
Date: 04 May 2003 15:01:05 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1052040665.1119.76.camel@lima.royalchallenge.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

sch_cbq.c: Trivial {del,add}_timer to mod_timer conversion.

--- linux-2.5.68/net/sched/sch_cbq.c	2003-03-25 10:08:36.000000000 +0530
+++ linux-2.5.68-nvk/net/sched/sch_cbq.c	2003-05-03 19:29:08.000000000 +0530
@@ -1056,11 +1056,9 @@
 		sch->stats.overlimits++;
 		if (q->wd_expires && !netif_queue_stopped(sch->dev)) {
 			long delay = PSCHED_US2JIFFIE(q->wd_expires);
-			del_timer(&q->wd_timer);
 			if (delay <= 0)
 				delay = 1;
-			q->wd_timer.expires = jiffies + delay;
-			add_timer(&q->wd_timer);
+			mod_timer(&q->wd_timer, jiffies + delay);
 			sch->flags |= TCQ_F_THROTTLED;
 		}
 	}
