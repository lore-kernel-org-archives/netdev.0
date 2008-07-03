From: Patrick McHardy <kaber@trash.net>
Subject: net-sched 00/06: dynamically sized class hashes v2
Date: Thu,  3 Jul 2008 17:16:01 +0200 (MEST)
Message-ID: <20080703151600.26225.3394.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, Patrick McHardy <kaber@trash.net>, jarkao2@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40211 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbYGCPQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 11:16:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches add support for dynamically sized class hash tables
to remove a major bottleneck in qdisc filters with many classes
when filters are not bound to classes and convert CBQ, HTB and HFSC
to use them.

Changes since the last posting are mostly suggestions from Martin
Devera and Jarek Poplawski:

- fix missing qdisc hash initialization in CBQ
- use classes directly in hlist iteration instead of Qdisc_class_common
- change qdisc_class_find to return Qdisc_class_common * instead of void *
- new patch to remove child and sibling lists from HTB
- all patches are tested now and considered ready for merging :)

The patches need the two filter destruction fixes that went into
net-2.6.git to apply cleanly, so they won't apply until net-2.6.git
is merged into net-next-2.6.git.


 include/net/sch_generic.h |   42 +++++++++++++
 net/sched/sch_api.c       |  104 ++++++++++++++++++++++++++++++++
 net/sched/sch_cbq.c       |  112 +++++++++++++++++------------------
 net/sched/sch_hfsc.c      |   81 ++++++++++++-------------
 net/sched/sch_htb.c       |  145 ++++++++++++++++++---------------------------
 5 files changed, 299 insertions(+), 185 deletions(-)

Patrick McHardy (6):
      net-sched: add dynamically sized qdisc class hash helpers
      net-sched: sch_hfsc: use dynamic class hash helpers
      net-sched: sch_cbq: use dynamic class hash helpers
      net-sched: sch_htb: move hash and sibling list removal to htb_delete
      net-sched: sch_htb: use dynamic class hash helpers
      net-sched: sch_htb: remove child and sibling lists
