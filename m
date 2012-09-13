From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH 2/4] net_sched: gred: eliminate redundant DP prio comparisons
Date: Thu, 13 Sep 2012 11:22:33 -0400
Message-ID: <1347549755-19438-2-git-send-email-david.ward@ll.mit.edu>
References: <1347549755-19438-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Bruce Osler <brosler@cisco.com>, Cyril Chemparathy <cyril@ti.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:52901 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758401Ab2IMP62 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2012 11:58:28 -0400
In-Reply-To: <1347549755-19438-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each pair of DPs only needs to be compared once when searching for
a non-unique prio value.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 net/sched/sch_gred.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index fca73cd..e19d4eb 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -102,9 +102,8 @@ static inline int gred_wred_mode_check(struct Qdisc *sch)
 		if (q == NULL)
 			continue;
 
-		for (n = 0; n < table->DPs; n++)
-			if (table->tab[n] && table->tab[n] != q &&
-			    table->tab[n]->prio == q->prio)
+		for (n = i + 1; n < table->DPs; n++)
+			if (table->tab[n] && table->tab[n]->prio == q->prio)
 				return 1;
 	}
 
-- 
1.7.4.1
