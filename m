From: Vinay K Nallamothu <vinay-rc@naturesoft.net>
Subject: [PATCH 2.{4,5}.x] mod_timer fix for sch_csz.c
Date: 04 May 2003 15:09:05 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1052041145.1119.83.camel@lima.royalchallenge.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--- linux-2.5.68/net/sched/sch_csz.c	2003-04-21 10:14:44.000000000 +0530
+++ linux-2.5.68-nvk/net/sched/sch_csz.c	2003-05-03 14:40:11.000000000 +0530
@@ -708,11 +708,9 @@
 	 */
 	if (q->wd_expires) {
 		unsigned long delay = PSCHED_US2JIFFIE(q->wd_expires);
-		del_timer(&q->wd_timer);
 		if (delay == 0)
 			delay = 1;
-		q->wd_timer.expires = jiffies + delay;
-		add_timer(&q->wd_timer);
+		mod_timer(&q->wd_timer, jiffies + delay);
 		sch->stats.overlimits++;
 	}
 #endif
