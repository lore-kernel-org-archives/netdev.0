From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH] net: sched: kill dead code in sch_choke.c
Date: Tue,  3 Nov 2015 19:01:41 +0100
Message-ID: <1446573701-7585-1-git-send-email-phil@nwl.cc>
Cc: Stephen Hemminger <shemming@brocade.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:56374 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755564AbbKCSBn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 13:01:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks like this has never been used at all.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/sched/sch_choke.c | 59 ---------------------------------------------------
 1 file changed, 59 deletions(-)

diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index 02bfd3d..5ffb8b8 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -553,65 +553,6 @@ static void choke_destroy(struct Qdisc *sch)
 	choke_free(q->tab);
 }
 
-static struct Qdisc *choke_leaf(struct Qdisc *sch, unsigned long arg)
-{
-	return NULL;
-}
-
-static unsigned long choke_get(struct Qdisc *sch, u32 classid)
-{
-	return 0;
-}
-
-static void choke_put(struct Qdisc *q, unsigned long cl)
-{
-}
-
-static unsigned long choke_bind(struct Qdisc *sch, unsigned long parent,
-				u32 classid)
-{
-	return 0;
-}
-
-static struct tcf_proto __rcu **choke_find_tcf(struct Qdisc *sch,
-					       unsigned long cl)
-{
-	struct choke_sched_data *q = qdisc_priv(sch);
-
-	if (cl)
-		return NULL;
-	return &q->filter_list;
-}
-
-static int choke_dump_class(struct Qdisc *sch, unsigned long cl,
-			  struct sk_buff *skb, struct tcmsg *tcm)
-{
-	tcm->tcm_handle |= TC_H_MIN(cl);
-	return 0;
-}
-
-static void choke_walk(struct Qdisc *sch, struct qdisc_walker *arg)
-{
-	if (!arg->stop) {
-		if (arg->fn(sch, 1, arg) < 0) {
-			arg->stop = 1;
-			return;
-		}
-		arg->count++;
-	}
-}
-
-static const struct Qdisc_class_ops choke_class_ops = {
-	.leaf		=	choke_leaf,
-	.get		=	choke_get,
-	.put		=	choke_put,
-	.tcf_chain	=	choke_find_tcf,
-	.bind_tcf	=	choke_bind,
-	.unbind_tcf	=	choke_put,
-	.dump		=	choke_dump_class,
-	.walk		=	choke_walk,
-};
-
 static struct sk_buff *choke_peek_head(struct Qdisc *sch)
 {
 	struct choke_sched_data *q = qdisc_priv(sch);
-- 
2.1.2
