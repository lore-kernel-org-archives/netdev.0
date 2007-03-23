From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 10/11]: qdisc: remove unnecessary memory barriers
Date: Fri, 23 Mar 2007 14:35:52 +0100 (MET)
Message-ID: <20070323133527.10264.10728.sendpatchset@localhost.localdomain>
References: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61441 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934285AbXCWNfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 09:35:53 -0400
In-Reply-To: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: qdisc: remove unnecessary memory barriers

We're holding dev->queue_lock in qdisc_watchdog_schedule and
qdisc_watchdog_cancel, no need for the barriers.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit e2459acd7dee06fb4d5e980f26c23d31db0e5de1
tree 47287fb285e9d920392863121e88e69e45779cbb
parent 8da4bcec7e54c8344c8fd77c72a61f24ce12cfc3
author Patrick McHardy <kaber@trash.net> Fri, 23 Mar 2007 10:31:31 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 23 Mar 2007 10:31:31 +0100

 net/sched/sch_api.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 5b5bce0..2e863bd 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -322,7 +322,6 @@ void qdisc_watchdog_schedule(struct qdisc_watchdog *wd, psched_time_t expires)
 	ktime_t time;
 
 	wd->qdisc->flags |= TCQ_F_THROTTLED;
-	smp_wmb();
 	time = ktime_set(0, 0);
 	time = ktime_add_ns(time, PSCHED_US2NS(expires));
 	hrtimer_start(&wd->timer, time, HRTIMER_MODE_ABS);
@@ -333,7 +332,6 @@ void qdisc_watchdog_cancel(struct qdisc_watchdog *wd)
 {
 	hrtimer_cancel(&wd->timer);
 	wd->qdisc->flags &= ~TCQ_F_THROTTLED;
-	smp_wmb();
 }
 EXPORT_SYMBOL(qdisc_watchdog_cancel);
 
