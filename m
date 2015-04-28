From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] net: sched: act_connmark: don't zap skb->nfct
Date: Tue, 28 Apr 2015 13:33:21 +0200
Message-ID: <1430220801-21798-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34233 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965150AbbD1Ldk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 07:33:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This action is meant to be passive, i.e. we should not alter
skb->nfct: If nfct is present just leave it alone.

Compile tested only.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
shouldn't matter much in practice since this would be used in the
ingress path where skb->nfct is NULL in non-lo case.
diff --git a/net/sched/act_connmark.c b/net/sched/act_connmark.c
index 8e47251..295d14b 100644
--- a/net/sched/act_connmark.c
+++ b/net/sched/act_connmark.c
@@ -63,7 +63,6 @@ static int tcf_connmark(struct sk_buff *skb, const struct tc_action *a,
 		skb->mark = c->mark;
 		/* using overlimits stats to count how many packets marked */
 		ca->tcf_qstats.overlimits++;
-		nf_ct_put(c);
 		goto out;
 	}
 
@@ -82,7 +81,6 @@ static int tcf_connmark(struct sk_buff *skb, const struct tc_action *a,
 	nf_ct_put(c);
 
 out:
-	skb->nfct = NULL;
 	spin_unlock(&ca->tcf_lock);
 	return ca->tcf_action;
 }
-- 
2.0.5
