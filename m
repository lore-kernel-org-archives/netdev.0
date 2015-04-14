From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 03/39] net: sched: Use hrtimer_resolution instead of
 hrtimer_get_res()
Date: Tue, 14 Apr 2015 21:08:28 -0000
Message-ID: <20150414203500.720623028@linutronix.de>
References: <20150414203303.702062272@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	Preeti U Murthy <preeti@linux.vnet.ibm.com>,
	Viresh Kumar <viresh.kumar@linaro.org>,
	Marcelo Tosatti <mtosatt@redhat.com>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:37928 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755196AbbDNVIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 17:08:19 -0400
Content-Disposition: inline; filename=net-sched-use-hrtimer-resolution.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No point in converting a timespec now that the value is directly
accessible.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---

@David: Depends on a previous patch in this series

 net/sched/sch_api.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

Index: tip/net/sched/sch_api.c
===================================================================
--- tip.orig/net/sched/sch_api.c
+++ tip/net/sched/sch_api.c
@@ -1879,13 +1879,10 @@ EXPORT_SYMBOL(tcf_destroy_chain);
 #ifdef CONFIG_PROC_FS
 static int psched_show(struct seq_file *seq, void *v)
 {
-	struct timespec ts;
-
-	hrtimer_get_res(CLOCK_MONOTONIC, &ts);
 	seq_printf(seq, "%08x %08x %08x %08x\n",
 		   (u32)NSEC_PER_USEC, (u32)PSCHED_TICKS2NS(1),
 		   1000000,
-		   (u32)NSEC_PER_SEC/(u32)ktime_to_ns(timespec_to_ktime(ts)));
+		   (u32)NSEC_PER_SEC / hrtimer_resolution);
 
 	return 0;
 }
