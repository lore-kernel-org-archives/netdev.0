From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 31/39] net: core: pktgen: Remove bogus hrtimer_active() check
Date: Tue, 14 Apr 2015 21:09:16 -0000
Message-ID: <20150414203503.165258315@linutronix.de>
References: <20150414203303.702062272@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	Preeti U Murthy <preeti@linux.vnet.ibm.com>,
	Viresh Kumar <viresh.kumar@linaro.org>,
	Marcelo Tosatti <mtosatt@redhat.com>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:38192 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932246AbbDNVJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 17:09:04 -0400
Content-Disposition: inline;
 filename=net-core-pktgen-remove-bogus-hrtimer-is-active-check.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The check for hrtimer_active() after starting the timer is
pointless. If the timer is inactive it has expired already and
therefor the task pointer is already NULL.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 net/core/pktgen.c |    2 --
 1 file changed, 2 deletions(-)

Index: tip/net/core/pktgen.c
===================================================================
--- tip.orig/net/core/pktgen.c
+++ tip/net/core/pktgen.c
@@ -2212,8 +2212,6 @@ static void spin(struct pktgen_dev *pkt_
 		do {
 			set_current_state(TASK_INTERRUPTIBLE);
 			hrtimer_start_expires(&t.timer, HRTIMER_MODE_ABS);
-			if (!hrtimer_active(&t.timer))
-				t.task = NULL;
 
 			if (likely(t.task))
 				schedule();
