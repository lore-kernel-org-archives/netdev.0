From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 1/3] pkt_sched: sch_htb: Remove htb_class aprio field
Date: Tue, 2 Dec 2008 08:56:22 +0000
Message-ID: <20081202085622.GA10412@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Devera <devik@cdi.cz>, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.183]:33105 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432AbYLBI43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 03:56:29 -0500
Received: by ik-out-1112.google.com with SMTP id c29so2379106ika.5
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2008 00:56:28 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove practically unused struct htb_class aprio field.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 net/sched/sch_htb.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 8a45199..ce8b1ad 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -88,7 +88,6 @@ struct htb_class {
 		struct htb_class_leaf {
 			struct Qdisc *q;
 			int prio;
-			int aprio;
 			int quantum;
 			int deficit[TC_HTB_MAXDEPTH];
 			struct list_head drop_list;
@@ -527,10 +526,10 @@ static inline void htb_activate(struct htb_sched *q, struct htb_class *cl)
 	WARN_ON(cl->level || !cl->un.leaf.q || !cl->un.leaf.q->q.qlen);
 
 	if (!cl->prio_activity) {
-		cl->prio_activity = 1 << (cl->un.leaf.aprio = cl->un.leaf.prio);
+		cl->prio_activity = 1 << cl->un.leaf.prio;
 		htb_activate_prios(q, cl);
 		list_add_tail(&cl->un.leaf.drop_list,
-			      q->drops + cl->un.leaf.aprio);
+			      q->drops + cl->un.leaf.prio);
 	}
 }
 
-- 
1.5.6.5

