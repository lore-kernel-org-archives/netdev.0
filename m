From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 02/11]: kill PSCHED_AUDIT_TDIFF
Date: Fri, 23 Mar 2007 14:35:41 +0100 (MET)
Message-ID: <20070323133516.10264.38355.sendpatchset@localhost.localdomain>
References: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61417 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934065AbXCWNfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 09:35:42 -0400
In-Reply-To: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: kill PSCHED_AUDIT_TDIFF

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 4a4a3d59dca71f202ab063b909c84c96c8ea09a7
tree 4958bfec571a3330bd023ebe50f7b071f6dc7dd7
parent 9f8c07452088f432c79ac3a8d87d6adebcce57df
author Patrick McHardy <kaber@trash.net> Thu, 22 Mar 2007 23:58:12 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 23 Mar 2007 10:31:27 +0100

 include/net/pkt_sched.h |    1 -
 net/sched/sch_cbq.c     |    2 --
 2 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 6555e57..276d1ad 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -59,7 +59,6 @@ typedef long	psched_tdiff_t;
 #define PSCHED_TADD(tv, delta)		((tv) += (delta))
 #define PSCHED_SET_PASTPERFECT(t)	((t) = 0)
 #define PSCHED_IS_PASTPERFECT(t)	((t) == 0)
-#define	PSCHED_AUDIT_TDIFF(t)
 
 struct qdisc_watchdog {
 	struct hrtimer	timer;
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index dcd9c31..57ac6c5 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -820,8 +820,6 @@ cbq_update(struct cbq_sched_data *q)
 			idle -= L2T(&q->link, len);
 			idle += L2T(cl, len);
 
-			PSCHED_AUDIT_TDIFF(idle);
-
 			PSCHED_TADD2(q->now, idle, cl->undertime);
 		} else {
 			/* Underlimit */
