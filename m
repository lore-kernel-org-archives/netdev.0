From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next] net_sched: return nla_nest_end() instead of skb->len
Date: Wed, 12 Mar 2014 10:20:32 +0800
Message-ID: <1394590832-11064-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <edumazet@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:45588 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755961AbaCLCUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 22:20:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nla_nest_end() already has return skb->len, so replace
return skb->len with return nla_nest_end instead().

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_atm.c      | 3 +--
 net/sched/sch_cbq.c      | 6 ++----
 net/sched/sch_fq.c       | 3 +--
 net/sched/sch_fq_codel.c | 3 +--
 net/sched/sch_hfsc.c     | 3 +--
 net/sched/sch_hhf.c      | 3 +--
 net/sched/sch_ingress.c  | 3 +--
 net/sched/sch_tbf.c      | 3 +--
 8 files changed, 9 insertions(+), 18 deletions(-)

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 1f9c31411f19..8449b337f9e3 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -623,8 +623,7 @@ static int atm_tc_dump_class(struct Qdisc *sch, unsigned long cl,
 		if (nla_put_u32(skb, TCA_ATM_EXCESS, 0))
 			goto nla_put_failure;
 	}
-	nla_nest_end(skb, nest);
-	return skb->len;
+	return nla_nest_end(skb, nest);
 
 nla_put_failure:
 	nla_nest_cancel(skb, nest);
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 2f80d01d42a6..ead526467cca 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1563,8 +1563,7 @@ static int cbq_dump(struct Qdisc *sch, struct sk_buff *skb)
 		goto nla_put_failure;
 	if (cbq_dump_attr(skb, &q->link) < 0)
 		goto nla_put_failure;
-	nla_nest_end(skb, nest);
-	return skb->len;
+	return nla_nest_end(skb, nest);
 
 nla_put_failure:
 	nla_nest_cancel(skb, nest);
@@ -1599,8 +1598,7 @@ cbq_dump_class(struct Qdisc *sch, unsigned long arg,
 		goto nla_put_failure;
 	if (cbq_dump_attr(skb, cl) < 0)
 		goto nla_put_failure;
-	nla_nest_end(skb, nest);
-	return skb->len;
+	return nla_nest_end(skb, nest);
 
 nla_put_failure:
 	nla_nest_cancel(skb, nest);
diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 21e251766eb1..23c682b42f99 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -781,8 +781,7 @@ static int fq_dump(struct Qdisc *sch, struct sk_buff *skb)
 	    nla_put_u32(skb, TCA_FQ_BUCKETS_LOG, q->fq_trees_log))
 		goto nla_put_failure;
 
-	nla_nest_end(skb, opts);
-	return skb->len;
+	return nla_nest_end(skb, opts);
 
 nla_put_failure:
 	return -1;
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index ba5bc929eac7..0bf432c782c1 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -450,8 +450,7 @@ static int fq_codel_dump(struct Qdisc *sch, struct sk_buff *skb)
 			q->flows_cnt))
 		goto nla_put_failure;
 
-	nla_nest_end(skb, opts);
-	return skb->len;
+	return nla_nest_end(skb, opts);
 
 nla_put_failure:
 	return -1;
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index c4075610502c..ec8aeaac1dd7 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1353,8 +1353,7 @@ hfsc_dump_class(struct Qdisc *sch, unsigned long arg, struct sk_buff *skb,
 		goto nla_put_failure;
 	if (hfsc_dump_curves(skb, cl) < 0)
 		goto nla_put_failure;
-	nla_nest_end(skb, nest);
-	return skb->len;
+	return nla_nest_end(skb, nest);
 
  nla_put_failure:
 	nla_nest_cancel(skb, nest);
diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index 647680b1c625..edee03d922e2 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -691,8 +691,7 @@ static int hhf_dump(struct Qdisc *sch, struct sk_buff *skb)
 	    nla_put_u32(skb, TCA_HHF_NON_HH_WEIGHT, q->hhf_non_hh_weight))
 		goto nla_put_failure;
 
-	nla_nest_end(skb, opts);
-	return skb->len;
+	return nla_nest_end(skb, opts);
 
 nla_put_failure:
 	return -1;
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index bce1665239b8..62871c14e1f9 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -100,8 +100,7 @@ static int ingress_dump(struct Qdisc *sch, struct sk_buff *skb)
 	nest = nla_nest_start(skb, TCA_OPTIONS);
 	if (nest == NULL)
 		goto nla_put_failure;
-	nla_nest_end(skb, nest);
-	return skb->len;
+	return nla_nest_end(skb, nest);
 
 nla_put_failure:
 	nla_nest_cancel(skb, nest);
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 87a02bfa707b..18ff63433709 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -475,8 +475,7 @@ static int tbf_dump(struct Qdisc *sch, struct sk_buff *skb)
 	    nla_put_u64(skb, TCA_TBF_PRATE64, q->peak.rate_bytes_ps))
 		goto nla_put_failure;
 
-	nla_nest_end(skb, nest);
-	return skb->len;
+	return nla_nest_end(skb, nest);
 
 nla_put_failure:
 	nla_nest_cancel(skb, nest);
-- 
1.8.0
