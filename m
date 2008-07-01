From: Patrick McHardy <kaber@trash.net>
Subject: [RFC]: net-sched 00/05: dynamically sized class hashes
Date: Tue,  1 Jul 2008 16:34:11 +0200 (MEST)
Message-ID: <20080701143410.26309.45560.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39056 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755199AbYGAOeM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 10:34:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches add support for dynamically sized class hash tables
to remove a major bottleneck in qdisc filters with many classes
when filters are not bound to classes and convert CBQ, HTB and HFSC
to use them.

Only RFC at this point because they haven't been tested thoroughly yet
and depend on the filter destruction fixes I sent this morning, but any
review (especially of 4/5, the htb_delete changes) is welcome.


 include/net/sch_generic.h |   41 +++++++++++++++
 net/sched/sch_api.c       |  104 ++++++++++++++++++++++++++++++++++++++
 net/sched/sch_cbq.c       |  114 +++++++++++++++++++++--------------------
 net/sched/sch_hfsc.c      |   90 ++++++++++++++++++---------------
 net/sched/sch_htb.c       |  123 +++++++++++++++++++++------------------------
 5 files changed, 310 insertions(+), 162 deletions(-)

Patrick McHardy (5):
      net-sched: add dynamically sized qdisc class hash helpers
      net-sched: sch_hfsc: use dynamic class hash helpers
      net-sched: sch_cbq: use dynamic class hash helpers
      net-sched: sch_htb: move hash and sibling list removal to htb_delete
      net-sched: sch_htb: use dynamic class hash helpers
