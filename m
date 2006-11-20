From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 00/06]: Fix endless dequeue loops
Date: Mon, 20 Nov 2006 14:08:35 +0100 (MET)
Message-ID: <20061120130834.22347.34853.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:6654 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S965834AbWKTNIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 08:08:36 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches fix endless qdisc dequeue loops caused by inaccurate
qlen counters that can be triggered quite easily when changing
things while packets are queued. Please read the individual changelog
entries for details.

I've split them into very small pieces for easier review in case we
want to put them in 2.6.19. The problem has always been present, so
it doesn't seem to affect many people.

Martin, can you please review the HTB parts? Thanks.


PS: If anyone wants to suggest a nicer name for qdisc_tree_decrease_qlen
I'll gladly send new patches :)


 include/net/sch_generic.h |    4 +++-
 net/sched/sch_api.c       |   38 ++++++++++++++++++++++++++++++++------
 net/sched/sch_atm.c       |    5 +++--
 net/sched/sch_cbq.c       |   10 ++++++----
 net/sched/sch_dsmark.c    |    7 ++++---
 net/sched/sch_generic.c   |    7 +++++--
 net/sched/sch_hfsc.c      |   26 ++++++++++++++++++--------
 net/sched/sch_htb.c       |   38 +++++++++++++++++++++++++++-----------
 net/sched/sch_netem.c     |    5 +++--
 net/sched/sch_prio.c      |   14 ++++++++++----
 net/sched/sch_red.c       |   14 +++++++++-----
 net/sched/sch_sfq.c       |    3 +++
 net/sched/sch_tbf.c       |   14 +++++++++-----
 13 files changed, 132 insertions(+), 53 deletions(-)

Patrick McHardy:
      [NET_SCHED]: sch_htb: perform qlen adjustment immediately in ->delete
      [NET_SCHED]: Set parent classid in default qdiscs
      [NET_SCHED]: Fix endless loops caused by inaccurate qlen counters (part 1)
      [NET_SCHED]: Fix endless loops (part 2): "simple" qdiscs
      [NET_SCHED]: Fix endless loops (part 3): HFSC
      [NET_SCHED]: Fix endless loops (part 4): HTB
