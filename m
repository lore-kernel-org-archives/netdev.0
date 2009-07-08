From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (
	possibly?caused by netem)
Date: Thu, 9 Jul 2009 00:07:49 +0200
Message-ID: <20090708220749.GA3666@ami.dom.local>
References: <200907031326.21822.andres@anarazel.de> <200907071811.27570.andres@anarazel.de> <20090708080852.GC3148@ami.dom.local> <200907081029.34527.andres@anarazel.de> <20090708091344.GD3148@ami.dom.local> <a5d9929e0907081444r4a1e0828taf538c686577f09c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andres Freund <andres@anarazel.de>,
	Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Joao Correia <joaomiguelcorreia@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:51319 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755171AbZGHWIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 18:08:11 -0400
Content-Disposition: inline
In-Reply-To: <a5d9929e0907081444r4a1e0828taf538c686577f09c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 08, 2009 at 10:44:47PM +0100, Joao Correia wrote:
> Hello again
Hello!

...
> So again, the only thing that stops that freeze is  `echo 0 >>
> /proc/sys/kernel/timer_migration`. Apologies for pointing you in the
> wrong direction.

No problem: the direction is almost right, we only need one U-turn ;-)
In case you're not bored or too bored, one little patch to check the
other side (after reverting the previous patch).

Thanks,
Jarek P.
---

 kernel/hrtimer.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/kernel/hrtimer.c b/kernel/hrtimer.c
index 9002958..23387e4 100644
--- a/kernel/hrtimer.c
+++ b/kernel/hrtimer.c
@@ -203,7 +203,7 @@ switch_hrtimer_base(struct hrtimer *timer, struct hrtimer_clock_base *base,
 	int cpu, preferred_cpu = -1;
 
 	cpu = smp_processor_id();
-#if defined(CONFIG_NO_HZ) && defined(CONFIG_SMP)
+#if 0
 	if (!pinned && get_sysctl_timer_migration() && idle_cpu(cpu)) {
 		preferred_cpu = get_nohz_load_balancer();
 		if (preferred_cpu >= 0)
