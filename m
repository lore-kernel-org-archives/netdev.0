From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 08/15]: Use NLA_PUT_STRING for string dumping
Date: Wed, 23 Jan 2008 17:36:47 +0100 (MET)
Message-ID: <20080123163606.6459.55066.sendpatchset@localhost.localdomain>
References: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49738 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754037AbYAWQgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 11:36:48 -0500
In-Reply-To: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: Use NLA_PUT_STRING for string dumping

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit ad688fbdf7dd0ebeb1b2fba0d7d2105bdf3c6de9
tree 68bb3e1dc3484d6ca0e7ddc55ad4e25864aaac84
parent bdd38a3b14cfa340da580f6e825d7f1142925926
author Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:12:55 +0100
committer Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:12:55 +0100

 net/sched/act_api.c |    4 ++--
 net/sched/act_ipt.c |    2 +-
 net/sched/cls_api.c |    2 +-
 net/sched/cls_fw.c  |    2 +-
 net/sched/cls_u32.c |    2 +-
 net/sched/sch_api.c |    4 ++--
 6 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 3602260..e33e43a 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -121,7 +121,7 @@ static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a,
 	nest = nla_nest_start(skb, a->order);
 	if (nest == NULL)
 		goto nla_put_failure;
-	NLA_PUT(skb, TCA_KIND, IFNAMSIZ, a->ops->kind);
+	NLA_PUT_STRING(skb, TCA_KIND, a->ops->kind);
 	for (i = 0; i < (hinfo->hmask + 1); i++) {
 		p = hinfo->htab[tcf_hash(i, hinfo->hmask)];
 
@@ -423,7 +423,7 @@ tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 	if (a->ops == NULL || a->ops->dump == NULL)
 		return err;
 
-	NLA_PUT(skb, TCA_KIND, IFNAMSIZ, a->ops->kind);
+	NLA_PUT_STRING(skb, TCA_KIND, a->ops->kind);
 	if (tcf_action_copy_stats(skb, a, 0))
 		goto nla_put_failure;
 	nest = nla_nest_start(skb, TCA_OPTIONS);
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 1269334..ecda51d 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -257,7 +257,7 @@ static int tcf_ipt_dump(struct sk_buff *skb, struct tc_action *a, int bind, int
 	NLA_PUT(skb, TCA_IPT_INDEX, 4, &ipt->tcf_index);
 	NLA_PUT(skb, TCA_IPT_HOOK, 4, &ipt->tcfi_hook);
 	NLA_PUT(skb, TCA_IPT_CNT, sizeof(struct tc_cnt), &c);
-	NLA_PUT(skb, TCA_IPT_TABLE, IFNAMSIZ, ipt->tcfi_tname);
+	NLA_PUT_STRING(skb, TCA_IPT_TABLE, ipt->tcfi_tname);
 	tm.install = jiffies_to_clock_t(jiffies - ipt->tcf_tm.install);
 	tm.lastuse = jiffies_to_clock_t(jiffies - ipt->tcf_tm.lastuse);
 	tm.expires = jiffies_to_clock_t(ipt->tcf_tm.expires);
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 5584e7c..3377ca0 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -337,7 +337,7 @@ static int tcf_fill_node(struct sk_buff *skb, struct tcf_proto *tp,
 	tcm->tcm_ifindex = tp->q->dev->ifindex;
 	tcm->tcm_parent = tp->classid;
 	tcm->tcm_info = TC_H_MAKE(tp->prio, tp->protocol);
-	NLA_PUT(skb, TCA_KIND, IFNAMSIZ, tp->ops->kind);
+	NLA_PUT_STRING(skb, TCA_KIND, tp->ops->kind);
 	tcm->tcm_handle = fh;
 	if (RTM_DELTFILTER != event) {
 		tcm->tcm_handle = 0;
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index e3dfbb3..3107473 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -352,7 +352,7 @@ static int fw_dump(struct tcf_proto *tp, unsigned long fh,
 		NLA_PUT(skb, TCA_FW_CLASSID, 4, &f->res.classid);
 #ifdef CONFIG_NET_CLS_IND
 	if (strlen(f->indev))
-		NLA_PUT(skb, TCA_FW_INDEV, IFNAMSIZ, f->indev);
+		NLA_PUT_STRING(skb, TCA_FW_INDEV, f->indev);
 #endif /* CONFIG_NET_CLS_IND */
 	if (head->mask != 0xFFFFFFFF)
 		NLA_PUT(skb, TCA_FW_MASK, 4, &head->mask);
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index b51c2c3..7a15025 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -732,7 +732,7 @@ static int u32_dump(struct tcf_proto *tp, unsigned long fh,
 
 #ifdef CONFIG_NET_CLS_IND
 		if(strlen(n->indev))
-			NLA_PUT(skb, TCA_U32_INDEV, IFNAMSIZ, n->indev);
+			NLA_PUT_STRING(skb, TCA_U32_INDEV, n->indev);
 #endif
 #ifdef CONFIG_CLS_U32_PERF
 		NLA_PUT(skb, TCA_U32_PCNT,
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 7abb028..8db554d 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -834,7 +834,7 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 	tcm->tcm_parent = clid;
 	tcm->tcm_handle = q->handle;
 	tcm->tcm_info = atomic_read(&q->refcnt);
-	NLA_PUT(skb, TCA_KIND, IFNAMSIZ, q->ops->id);
+	NLA_PUT_STRING(skb, TCA_KIND, q->ops->id);
 	if (q->ops->dump && q->ops->dump(q, skb) < 0)
 		goto nla_put_failure;
 	q->qstats.qlen = q->q.qlen;
@@ -1080,7 +1080,7 @@ static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
 	tcm->tcm_parent = q->handle;
 	tcm->tcm_handle = q->handle;
 	tcm->tcm_info = 0;
-	NLA_PUT(skb, TCA_KIND, IFNAMSIZ, q->ops->id);
+	NLA_PUT_STRING(skb, TCA_KIND, q->ops->id);
 	if (cl_ops->dump && cl_ops->dump(q, cl, skb, tcm) < 0)
 		goto nla_put_failure;
 
