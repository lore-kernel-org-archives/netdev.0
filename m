From: Vinay K Nallamothu <vinay-rc@naturesoft.net>
Subject: [PATCH 2.{4,5}.x] mod_timer fix for sch_htb.c
Date: 04 May 2003 15:10:42 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1052041242.1245.86.camel@lima.royalchallenge.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

sch_htb.c: Trivial {del,add}_timer to mod_timer conversion.

--- linux-2.5.68/net/sched/sch_htb.c	2003-04-21 10:14:44.000000000 +0530
+++ linux-2.5.68-nvk/net/sched/sch_htb.c	2003-05-03 14:41:36.000000000 +0530
@@ -975,9 +975,7 @@
 			printk(KERN_INFO "HTB delay %ld > 5sec\n", delay);
 		delay = 5*HZ;
 	}
-	del_timer(&q->timer);
-	q->timer.expires = jiffies + delay;
-	add_timer(&q->timer);
+	mod_timer(&q->timer, jiffies + delay);
 	sch->flags |= TCQ_F_THROTTLED;
 	sch->stats.overlimits++;
 	HTB_DBG(3,1,"htb_deq t_delay=%ld\n",delay);
