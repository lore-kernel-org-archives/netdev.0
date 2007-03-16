From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 00/10]: ktime clocksource + hrtimer
Date: Fri, 16 Mar 2007 06:30:48 +0100 (MET)
Message-ID: <20070316053018.22744.76883.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	shemminger@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45237 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128AbXCPFau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 01:30:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches convert the packet schedulers to use ktime as only clock
source and kill off the manual clock source selection. Additionally all
packet schedulers are converted to use hrtimer-based watchdogs, greatly
increasing scheduling precision.

I've tested HFSC, HTB, TBF and netem. CBQ is untested since I never
managed to get it running properly even without these patches.

I have a number of follow-up cleanup patches that get rid of most of
the remaining PSCHED_* macros, I'll send them once these patches have
been merged.

Please apply, thanks.


 include/net/pkt_sched.h |  182 ++++++------------------------------------------
 kernel/hrtimer.c        |    1 
 net/sched/Kconfig       |   56 --------------
 net/sched/sch_api.c     |  113 ++++++++++-------------------
 net/sched/sch_cbq.c     |  100 ++++++++++++--------------
 net/sched/sch_hfsc.c    |   75 ++++---------------
 net/sched/sch_htb.c     |   93 ++++++++----------------
 net/sched/sch_netem.c   |   25 +-----
 net/sched/sch_tbf.c     |   31 +-------
 9 files changed, 171 insertions(+), 505 deletions(-)

Patrick McHardy:
      [NET_SCHED]: Use ktime as clocksource
      [NET_SCHED]: Add hrtimer based qdisc watchdog
      [NET_SCHED]: sch_hfsc: use hrtimer based watchdog
      [NET_SCHED]: sch_tbf: use hrtimer based watchdog
      [NET_SCHED]: sch_netem: use hrtimer based watchdog
      [NET_SCHED]: sch_cbq: use hrtimer based watchdog
      [NET_SCHED]: sch_cbq: fix cbq_undelay_prio for non-active priorites
      [NET_SCHED]: sch_cbq: use hrtimer for delay_timer
      [NET_SCHED]: sch_htb: use hrtimer based watchdog
      [NET_SCHED]: kill jiffie conversion macros
