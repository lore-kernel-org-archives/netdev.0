From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 09/15]: Use typeful attribute construction helpers
Date: Wed, 23 Jan 2008 17:36:48 +0100 (MET)
Message-ID: <20080123163607.6459.38444.sendpatchset@localhost.localdomain>
References: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49742 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754258AbYAWQgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 11:36:50 -0500
In-Reply-To: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: Use typeful attribute construction helpers

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 04d3c2781cba0b4ab75005de0defdb2a58178f21
tree a1b904b7f29ad1ff7cff310128b3fd67e2543278
parent ad688fbdf7dd0ebeb1b2fba0d7d2105bdf3c6de9
author Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:12:55 +0100
committer Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:12:55 +0100

 net/sched/act_api.c     |    2 +-
 net/sched/act_ipt.c     |    4 ++--
 net/sched/act_police.c  |    5 ++---
 net/sched/cls_basic.c   |    2 +-
 net/sched/cls_fw.c      |    4 ++--
 net/sched/cls_route.c   |    8 ++++----
 net/sched/cls_rsvp.h    |    2 +-
 net/sched/cls_tcindex.c |   11 +++++------
 net/sched/cls_u32.c     |    8 ++++----
 net/sched/em_meta.c     |    3 +--
 net/sched/sch_atm.c     |    8 +++-----
 11 files changed, 26 insertions(+), 31 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index e33e43a..41fbd49 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -133,7 +133,7 @@ static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a,
 			p = s_p;
 		}
 	}
-	NLA_PUT(skb, TCA_FCNT, 4, &n_i);
+	NLA_PUT_U32(skb, TCA_FCNT, n_i);
 	nla_nest_end(skb, nest);
 
 	return n_i;
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index ecda51d..5dd701a 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -254,8 +254,8 @@ static int tcf_ipt_dump(struct sk_buff *skb, struct tc_action *a, int bind, int
 	strcpy(t->u.user.name, ipt->tcfi_t->u.kernel.target->name);
 
 	NLA_PUT(skb, TCA_IPT_TARG, ipt->tcfi_t->u.user.target_size, t);
-	NLA_PUT(skb, TCA_IPT_INDEX, 4, &ipt->tcf_index);
-	NLA_PUT(skb, TCA_IPT_HOOK, 4, &ipt->tcfi_hook);
+	NLA_PUT_U32(skb, TCA_IPT_INDEX, ipt->tcf_index);
+	NLA_PUT_U32(skb, TCA_IPT_HOOK, ipt->tcfi_hook);
 	NLA_PUT(skb, TCA_IPT_CNT, sizeof(struct tc_cnt), &c);
 	NLA_PUT_STRING(skb, TCA_IPT_TABLE, ipt->tcfi_tname);
 	tm.install = jiffies_to_clock_t(jiffies - ipt->tcf_tm.install);
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index ee2f1b6..79db6bb 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -339,10 +339,9 @@ tcf_act_police_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 		memset(&opt.peakrate, 0, sizeof(opt.peakrate));
 	NLA_PUT(skb, TCA_POLICE_TBF, sizeof(opt), &opt);
 	if (police->tcfp_result)
-		NLA_PUT(skb, TCA_POLICE_RESULT, sizeof(int),
-			&police->tcfp_result);
+		NLA_PUT_U32(skb, TCA_POLICE_RESULT, police->tcfp_result);
 	if (police->tcfp_ewma_rate)
-		NLA_PUT(skb, TCA_POLICE_AVRATE, 4, &police->tcfp_ewma_rate);
+		NLA_PUT_U32(skb, TCA_POLICE_AVRATE, police->tcfp_ewma_rate);
 	return skb->len;
 
 nla_put_failure:
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 6d08b42..58444fe 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -258,7 +258,7 @@ static int basic_dump(struct tcf_proto *tp, unsigned long fh,
 		goto nla_put_failure;
 
 	if (f->res.classid)
-		NLA_PUT(skb, TCA_BASIC_CLASSID, sizeof(u32), &f->res.classid);
+		NLA_PUT_U32(skb, TCA_BASIC_CLASSID, f->res.classid);
 
 	if (tcf_exts_dump(skb, &f->exts, &basic_ext_map) < 0 ||
 	    tcf_em_tree_dump(skb, &f->ematches, TCA_BASIC_EMATCHES) < 0)
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 3107473..61ebe25 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -349,13 +349,13 @@ static int fw_dump(struct tcf_proto *tp, unsigned long fh,
 		goto nla_put_failure;
 
 	if (f->res.classid)
-		NLA_PUT(skb, TCA_FW_CLASSID, 4, &f->res.classid);
+		NLA_PUT_U32(skb, TCA_FW_CLASSID, f->res.classid);
 #ifdef CONFIG_NET_CLS_IND
 	if (strlen(f->indev))
 		NLA_PUT_STRING(skb, TCA_FW_INDEV, f->indev);
 #endif /* CONFIG_NET_CLS_IND */
 	if (head->mask != 0xFFFFFFFF)
-		NLA_PUT(skb, TCA_FW_MASK, 4, &head->mask);
+		NLA_PUT_U32(skb, TCA_FW_MASK, head->mask);
 
 	if (tcf_exts_dump(skb, &f->exts, &fw_ext_map) < 0)
 		goto nla_put_failure;
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 1ce1f36..7752586 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -565,17 +565,17 @@ static int route4_dump(struct tcf_proto *tp, unsigned long fh,
 
 	if (!(f->handle&0x8000)) {
 		id = f->id&0xFF;
-		NLA_PUT(skb, TCA_ROUTE4_TO, sizeof(id), &id);
+		NLA_PUT_U32(skb, TCA_ROUTE4_TO, id);
 	}
 	if (f->handle&0x80000000) {
 		if ((f->handle>>16) != 0xFFFF)
-			NLA_PUT(skb, TCA_ROUTE4_IIF, sizeof(f->iif), &f->iif);
+			NLA_PUT_U32(skb, TCA_ROUTE4_IIF, f->iif);
 	} else {
 		id = f->id>>16;
-		NLA_PUT(skb, TCA_ROUTE4_FROM, sizeof(id), &id);
+		NLA_PUT_U32(skb, TCA_ROUTE4_FROM, id);
 	}
 	if (f->res.classid)
-		NLA_PUT(skb, TCA_ROUTE4_CLASSID, 4, &f->res.classid);
+		NLA_PUT_U32(skb, TCA_ROUTE4_CLASSID, f->res.classid);
 
 	if (tcf_exts_dump(skb, &f->exts, &route_ext_map) < 0)
 		goto nla_put_failure;
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 77097e0..838a3ff 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -617,7 +617,7 @@ static int rsvp_dump(struct tcf_proto *tp, unsigned long fh,
 	pinfo.pad = 0;
 	NLA_PUT(skb, TCA_RSVP_PINFO, sizeof(pinfo), &pinfo);
 	if (f->res.classid)
-		NLA_PUT(skb, TCA_RSVP_CLASSID, 4, &f->res.classid);
+		NLA_PUT_U32(skb, TCA_RSVP_CLASSID, f->res.classid);
 	if (((f->handle>>8)&0xFF) != 16)
 		NLA_PUT(skb, TCA_RSVP_SRC, sizeof(f->src), f->src);
 
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index cd350d3..7d46df7 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -449,11 +449,10 @@ static int tcindex_dump(struct tcf_proto *tp, unsigned long fh,
 
 	if (!fh) {
 		t->tcm_handle = ~0; /* whatever ... */
-		NLA_PUT(skb, TCA_TCINDEX_HASH, sizeof(p->hash), &p->hash);
-		NLA_PUT(skb, TCA_TCINDEX_MASK, sizeof(p->mask), &p->mask);
-		NLA_PUT(skb, TCA_TCINDEX_SHIFT, sizeof(p->shift), &p->shift);
-		NLA_PUT(skb, TCA_TCINDEX_FALL_THROUGH, sizeof(p->fall_through),
-		    &p->fall_through);
+		NLA_PUT_U32(skb, TCA_TCINDEX_HASH, p->hash);
+		NLA_PUT_U16(skb, TCA_TCINDEX_MASK, p->mask);
+		NLA_PUT_U32(skb, TCA_TCINDEX_SHIFT, p->shift);
+		NLA_PUT_U32(skb, TCA_TCINDEX_FALL_THROUGH, p->fall_through);
 		nla_nest_end(skb, nest);
 	} else {
 		if (p->perfect) {
@@ -473,7 +472,7 @@ static int tcindex_dump(struct tcf_proto *tp, unsigned long fh,
 		}
 		pr_debug("handle = %d\n", t->tcm_handle);
 		if (r->res.class)
-			NLA_PUT(skb, TCA_TCINDEX_CLASSID, 4, &r->res.classid);
+			NLA_PUT_U32(skb, TCA_TCINDEX_CLASSID, r->res.classid);
 
 		if (tcf_exts_dump(skb, &r->exts, &tcindex_ext_map) < 0)
 			goto nla_put_failure;
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 7a15025..326711e 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -708,19 +708,19 @@ static int u32_dump(struct tcf_proto *tp, unsigned long fh,
 	if (TC_U32_KEY(n->handle) == 0) {
 		struct tc_u_hnode *ht = (struct tc_u_hnode*)fh;
 		u32 divisor = ht->divisor+1;
-		NLA_PUT(skb, TCA_U32_DIVISOR, 4, &divisor);
+		NLA_PUT_U32(skb, TCA_U32_DIVISOR, divisor);
 	} else {
 		NLA_PUT(skb, TCA_U32_SEL,
 			sizeof(n->sel) + n->sel.nkeys*sizeof(struct tc_u32_key),
 			&n->sel);
 		if (n->ht_up) {
 			u32 htid = n->handle & 0xFFFFF000;
-			NLA_PUT(skb, TCA_U32_HASH, 4, &htid);
+			NLA_PUT_U32(skb, TCA_U32_HASH, htid);
 		}
 		if (n->res.classid)
-			NLA_PUT(skb, TCA_U32_CLASSID, 4, &n->res.classid);
+			NLA_PUT_U32(skb, TCA_U32_CLASSID, n->res.classid);
 		if (n->ht_down)
-			NLA_PUT(skb, TCA_U32_LINK, 4, &n->ht_down->handle);
+			NLA_PUT_U32(skb, TCA_U32_LINK, n->ht_down->handle);
 
 #ifdef CONFIG_CLS_U32_MARK
 		if (n->mark.val || n->mark.mask)
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index dd57236..63ae6a2 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -623,8 +623,7 @@ static int meta_int_dump(struct sk_buff *skb, struct meta_value *v, int tlv)
 	if (v->len == sizeof(unsigned long))
 		NLA_PUT(skb, tlv, sizeof(unsigned long), &v->val);
 	else if (v->len == sizeof(u32)) {
-		u32 d = v->val;
-		NLA_PUT(skb, tlv, sizeof(d), &d);
+		NLA_PUT_U32(skb, tlv, v->val);
 	}
 
 	return 0;
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 19c0007..4d87659 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -629,14 +629,12 @@ static int atm_tc_dump_class(struct Qdisc *sch, unsigned long cl,
 		pvc.sap_addr.vci = flow->vcc->vci;
 		NLA_PUT(skb, TCA_ATM_ADDR, sizeof(pvc), &pvc);
 		state = ATM_VF2VS(flow->vcc->flags);
-		NLA_PUT(skb, TCA_ATM_STATE, sizeof(state), &state);
+		NLA_PUT_U32(skb, TCA_ATM_STATE, state);
 	}
 	if (flow->excess)
-		NLA_PUT(skb, TCA_ATM_EXCESS, sizeof(u32), &flow->classid);
+		NLA_PUT_U32(skb, TCA_ATM_EXCESS, flow->classid);
 	else {
-		static u32 zero;
-
-		NLA_PUT(skb, TCA_ATM_EXCESS, sizeof(zero), &zero);
+		NLA_PUT_U32(skb, TCA_ATM_EXCESS, 0);
 	}
 
 	nla_nest_end(skb, nest);
