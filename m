From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 00/11]: pkt_sched.h cleanup + misc changes
Date: Fri, 23 Mar 2007 14:35:38 +0100 (MET)
Message-ID: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61410 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934045AbXCWNfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 09:35:40 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches fix an off-by-one in netem, clean up pkt_sched.h by removing
most of the now unnecessary PSCHED time macros and turning the two remaining
ones into inline functions, consolidate some common filter destruction code
and move the TCQ_F_THROTTLED optimization from netem to qdisc_restart.

Please apply, thanks.


 include/net/pkt_sched.h   |   24 +++++++-------
 include/net/red.h         |   10 +++---
 include/net/sch_generic.h |   10 +-----
 net/sched/act_police.c    |   17 ++++------
 net/sched/sch_api.c       |   20 ++++++++++--
 net/sched/sch_atm.c       |   17 +---------
 net/sched/sch_cbq.c       |   76 ++++++++++++++++++----------------------------
 net/sched/sch_dsmark.c    |    8 ----
 net/sched/sch_generic.c   |    4 ++
 net/sched/sch_hfsc.c      |   23 +++----------
 net/sched/sch_htb.c       |   24 ++++----------
 net/sched/sch_ingress.c   |    7 ----
 net/sched/sch_netem.c     |   24 +++++---------
 net/sched/sch_prio.c      |    7 ----
 net/sched/sch_tbf.c       |    9 ++---
 15 files changed, 110 insertions(+), 170 deletions(-)

Patrick McHardy (11):
      [NET_SCHED]: sch_netem: fix off-by-one in send time comparison
      [NET_SCHED]: kill PSCHED_AUDIT_TDIFF
      [NET_SCHED]: kill PSCHED_TADD/PSCHED_TADD2
      [NET_SCHED]: kill PSCHED_TLESS
      [NET_SCHED]: kill PSCHED_SET_PASTPERFECT/PSCHED_IS_PASTPERFECT
      [NET_SCHED]: kill PSCHED_TDIFF
      [NET_SCHED]: turn PSCHED_TDIFF_SAFE into inline function
      [NET_SCHED]: turn PSCHED_GET_TIME into inline function
      [NET_SCHED]: Unline tcf_destroy
      [NET_SCHED]: qdisc: remove unnecessary memory barriers
      [NET_SCHED]: qdisc: avoid dequeue while throttled
