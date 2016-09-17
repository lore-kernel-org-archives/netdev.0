From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 4/5] sched: replace __skb_dequeue with __qdisc_dequeue_head
Date: Sun, 18 Sep 2016 00:57:33 +0200
Message-ID: <1474153054-9059-5-git-send-email-fw@strlen.de>
References: <1474153054-9059-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:51390 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932125AbcIQW5j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 18:57:39 -0400
In-Reply-To: <1474153054-9059-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After previous patch these functions are identical.
Replace __skb_dequeue in qdiscs with __qdisc_dequeue_head.

Next patch will then make __qdisc_dequeue_head handle
single-linked list instead of strcut sk_buff_head argument.

Doesn't change generated code.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/sched/sch_codel.c | 4 ++--
 net/sched/sch_netem.c | 2 +-
 net/sched/sch_pie.c   | 2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_codel.c b/net/sched/sch_codel.c
index 4002df3..5bfa79e 100644
--- a/net/sched/sch_codel.c
+++ b/net/sched/sch_codel.c
@@ -69,7 +69,7 @@ struct codel_sched_data {
 static struct sk_buff *dequeue_func(struct codel_vars *vars, void *ctx)
 {
 	struct Qdisc *sch = ctx;
-	struct sk_buff *skb = __skb_dequeue(&sch->q);
+	struct sk_buff *skb = __qdisc_dequeue_head(&sch->q);
 
 	if (skb)
 		sch->qstats.backlog -= qdisc_pkt_len(skb);
@@ -172,7 +172,7 @@ static int codel_change(struct Qdisc *sch, struct nlattr *opt)
 
 	qlen = sch->q.qlen;
 	while (sch->q.qlen > sch->limit) {
-		struct sk_buff *skb = __skb_dequeue(&sch->q);
+		struct sk_buff *skb = __qdisc_dequeue_head(&sch->q);
 
 		dropped += qdisc_pkt_len(skb);
 		qdisc_qstats_backlog_dec(sch, skb);
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 1832d77..0a964b3 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -587,7 +587,7 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 	struct rb_node *p;
 
 tfifo_dequeue:
-	skb = __skb_dequeue(&sch->q);
+	skb = __qdisc_dequeue_head(&sch->q);
 	if (skb) {
 		qdisc_qstats_backlog_dec(sch, skb);
 deliver:
diff --git a/net/sched/sch_pie.c b/net/sched/sch_pie.c
index d976d74..5c3a99d 100644
--- a/net/sched/sch_pie.c
+++ b/net/sched/sch_pie.c
@@ -231,7 +231,7 @@ static int pie_change(struct Qdisc *sch, struct nlattr *opt)
 	/* Drop excess packets if new limit is lower */
 	qlen = sch->q.qlen;
 	while (sch->q.qlen > sch->limit) {
-		struct sk_buff *skb = __skb_dequeue(&sch->q);
+		struct sk_buff *skb = __qdisc_dequeue_head(&sch->q);
 
 		dropped += qdisc_pkt_len(skb);
 		qdisc_qstats_backlog_dec(sch, skb);
-- 
2.7.3
