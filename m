From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 07/10]: sch_cbq: fix cbq_undelay_prio for non-active priorites
Date: Fri, 16 Mar 2007 06:30:58 +0100 (MET)
Message-ID: <20070316053028.22744.75302.sendpatchset@localhost.localdomain>
References: <20070316053018.22744.76883.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	shemminger@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45272 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752423AbXCPFa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 01:30:59 -0400
In-Reply-To: <20070316053018.22744.76883.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: sch_cbq: fix cbq_undelay_prio for non-active priorites

cbq_undelay_prio is supposed to return a time delta, but returns the
current time for non-active priorities, causing cbq_undelay to mark
the priority as active and schedule a timer for twice the current
time.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 40c78645115590d29549f6a1603847a620206d29
tree 256ba8884abb84aedaec857800a93a0619f9195e
parent dc1a944b36eeddc06e7288a2eec9344252d4ccb7
author Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 06:06:29 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 06:06:29 +0100

 net/sched/sch_cbq.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index d29d121..32f6a30 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -612,7 +612,7 @@ static unsigned long cbq_undelay_prio(st
 	unsigned long sched = now;
 
 	if (cl_prev == NULL)
-		return now;
+		return 0;
 
 	do {
 		cl = cl_prev->next_alive;
