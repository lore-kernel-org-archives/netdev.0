From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 10/15]: Use typeful attribute parsing helpers
Date: Wed, 23 Jan 2008 17:36:50 +0100 (MET)
Message-ID: <20080123163609.6459.65018.sendpatchset@localhost.localdomain>
References: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49730 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753975AbYAWQgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 11:36:50 -0500
In-Reply-To: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: Use typeful attribute parsing helpers

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 3e73383f7c353af51e8cc475f1c217a6b81fcecf
tree 53d369ca2ffca26cf46c57d2a9043d53da7474f8
parent 04d3c2781cba0b4ab75005de0defdb2a58178f21
author Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:12:56 +0100
committer Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:12:56 +0100

 net/sched/act_api.c     |    2 +-
 net/sched/act_ipt.c     |    4 ++--
 net/sched/act_police.c  |    5 ++---
 net/sched/cls_basic.c   |    2 +-
 net/sched/cls_fw.c      |    6 +++---
 net/sched/cls_route.c   |    8 ++++----
 net/sched/cls_rsvp.h    |    4 ++--
 net/sched/cls_tcindex.c |   11 +++++------
 net/sched/cls_u32.c     |    8 ++++----
 net/sched/em_meta.c     |    2 +-
 net/sched/sch_atm.c     |    4 ++--
 11 files changed, 27 insertions(+), 29 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 41fbd49..0b8eb23 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -690,7 +690,7 @@ tcf_action_get_1(struct nlattr *nla, struct nlmsghdr *n, u32 pid)
 	if (tb[TCA_ACT_INDEX] == NULL ||
 	    nla_len(tb[TCA_ACT_INDEX]) < sizeof(index))
 		goto err_out;
-	index = *(int *)nla_data(tb[TCA_ACT_INDEX]);
+	index = nla_get_u32(tb[TCA_ACT_INDEX]);
 
 	err = -ENOMEM;
 	a = kzalloc(sizeof(struct tc_action), GFP_KERNEL);
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 5dd701a..7ab2419 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -123,7 +123,7 @@ static int tcf_ipt_init(struct nlattr *nla, struct nlattr *est,
 
 	if (tb[TCA_IPT_INDEX] != NULL &&
 	    nla_len(tb[TCA_IPT_INDEX]) >= sizeof(u32))
-		index = *(u32 *)nla_data(tb[TCA_IPT_INDEX]);
+		index = nla_get_u32(tb[TCA_IPT_INDEX]);
 
 	pc = tcf_hash_check(index, a, bind, &ipt_hash_info);
 	if (!pc) {
@@ -140,7 +140,7 @@ static int tcf_ipt_init(struct nlattr *nla, struct nlattr *est,
 	}
 	ipt = to_ipt(pc);
 
-	hook = *(u32 *)nla_data(tb[TCA_IPT_HOOK]);
+	hook = nla_get_u32(tb[TCA_IPT_HOOK]);
 
 	err = -ENOMEM;
 	tname = kmalloc(IFNAMSIZ, GFP_KERNEL);
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 79db6bb..62de806 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -203,7 +203,7 @@ override:
 	}
 
 	if (tb[TCA_POLICE_RESULT])
-		police->tcfp_result = *(u32*)nla_data(tb[TCA_POLICE_RESULT]);
+		police->tcfp_result = nla_get_u32(tb[TCA_POLICE_RESULT]);
 	police->tcfp_toks = police->tcfp_burst = parm->burst;
 	police->tcfp_mtu = parm->mtu;
 	if (police->tcfp_mtu == 0) {
@@ -216,8 +216,7 @@ override:
 	police->tcf_action = parm->action;
 
 	if (tb[TCA_POLICE_AVRATE])
-		police->tcfp_ewma_rate =
-			*(u32*)nla_data(tb[TCA_POLICE_AVRATE]);
+		police->tcfp_ewma_rate = nla_get_u32(tb[TCA_POLICE_AVRATE]);
 	if (est)
 		gen_replace_estimator(&police->tcf_bstats,
 				      &police->tcf_rate_est,
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 58444fe..0c872a7 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -150,7 +150,7 @@ static inline int basic_set_parms(struct tcf_proto *tp, struct basic_filter *f,
 		goto errout;
 
 	if (tb[TCA_BASIC_CLASSID]) {
-		f->res.classid = *(u32*)nla_data(tb[TCA_BASIC_CLASSID]);
+		f->res.classid = nla_get_u32(tb[TCA_BASIC_CLASSID]);
 		tcf_bind_filter(tp, &f->res, base);
 	}
 
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 61ebe25..b75696d 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -203,7 +203,7 @@ fw_change_attrs(struct tcf_proto *tp, struct fw_filter *f,
 	if (tb[TCA_FW_CLASSID]) {
 		if (nla_len(tb[TCA_FW_CLASSID]) != sizeof(u32))
 			goto errout;
-		f->res.classid = *(u32*)nla_data(tb[TCA_FW_CLASSID]);
+		f->res.classid = nla_get_u32(tb[TCA_FW_CLASSID]);
 		tcf_bind_filter(tp, &f->res, base);
 	}
 
@@ -218,7 +218,7 @@ fw_change_attrs(struct tcf_proto *tp, struct fw_filter *f,
 	if (tb[TCA_FW_MASK]) {
 		if (nla_len(tb[TCA_FW_MASK]) != sizeof(u32))
 			goto errout;
-		mask = *(u32*)nla_data(tb[TCA_FW_MASK]);
+		mask = nla_get_u32(tb[TCA_FW_MASK]);
 		if (mask != head->mask)
 			goto errout;
 	} else if (head->mask != 0xFFFFFFFF)
@@ -264,7 +264,7 @@ static int fw_change(struct tcf_proto *tp, unsigned long base,
 		if (tb[TCA_FW_MASK]) {
 			if (nla_len(tb[TCA_FW_MASK]) != sizeof(u32))
 				return -EINVAL;
-			mask = *(u32*)nla_data(tb[TCA_FW_MASK]);
+			mask = nla_get_u32(tb[TCA_FW_MASK]);
 		}
 
 		head = kzalloc(sizeof(struct fw_head), GFP_KERNEL);
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 7752586..ae97238 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -348,7 +348,7 @@ static int route4_set_parms(struct tcf_proto *tp, unsigned long base,
 			goto errout;
 		if (nla_len(tb[TCA_ROUTE4_TO]) < sizeof(u32))
 			goto errout;
-		to = *(u32*)nla_data(tb[TCA_ROUTE4_TO]);
+		to = nla_get_u32(tb[TCA_ROUTE4_TO]);
 		if (to > 0xFF)
 			goto errout;
 		nhandle = to;
@@ -359,14 +359,14 @@ static int route4_set_parms(struct tcf_proto *tp, unsigned long base,
 			goto errout;
 		if (nla_len(tb[TCA_ROUTE4_FROM]) < sizeof(u32))
 			goto errout;
-		id = *(u32*)nla_data(tb[TCA_ROUTE4_FROM]);
+		id = nla_get_u32(tb[TCA_ROUTE4_FROM]);
 		if (id > 0xFF)
 			goto errout;
 		nhandle |= id << 16;
 	} else if (tb[TCA_ROUTE4_IIF]) {
 		if (nla_len(tb[TCA_ROUTE4_IIF]) < sizeof(u32))
 			goto errout;
-		id = *(u32*)nla_data(tb[TCA_ROUTE4_IIF]);
+		id = nla_get_u32(tb[TCA_ROUTE4_IIF]);
 		if (id > 0x7FFF)
 			goto errout;
 		nhandle |= (id | 0x8000) << 16;
@@ -411,7 +411,7 @@ static int route4_set_parms(struct tcf_proto *tp, unsigned long base,
 	tcf_tree_unlock(tp);
 
 	if (tb[TCA_ROUTE4_CLASSID]) {
-		f->res.classid = *(u32*)nla_data(tb[TCA_ROUTE4_CLASSID]);
+		f->res.classid = nla_get_u32(tb[TCA_ROUTE4_CLASSID]);
 		tcf_bind_filter(tp, &f->res, base);
 	}
 
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 838a3ff..61286a0 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -430,7 +430,7 @@ static int rsvp_change(struct tcf_proto *tp, unsigned long base,
 		if (f->handle != handle && handle)
 			goto errout2;
 		if (tb[TCA_RSVP_CLASSID-1]) {
-			f->res.classid = *(u32*)nla_data(tb[TCA_RSVP_CLASSID-1]);
+			f->res.classid = nla_get_u32(tb[TCA_RSVP_CLASSID-1]);
 			tcf_bind_filter(tp, &f->res, base);
 		}
 
@@ -470,7 +470,7 @@ static int rsvp_change(struct tcf_proto *tp, unsigned long base,
 		err = -EINVAL;
 		if (nla_len(tb[TCA_RSVP_CLASSID-1]) != 4)
 			goto errout;
-		f->res.classid = *(u32*)nla_data(tb[TCA_RSVP_CLASSID-1]);
+		f->res.classid = nla_get_u32(tb[TCA_RSVP_CLASSID-1]);
 	}
 
 	err = -EINVAL;
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 7d46df7..2809856 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -221,19 +221,19 @@ tcindex_set_parms(struct tcf_proto *tp, unsigned long base, u32 handle,
 	if (tb[TCA_TCINDEX_HASH]) {
 		if (nla_len(tb[TCA_TCINDEX_HASH]) < sizeof(u32))
 			goto errout;
-		cp.hash = *(u32 *) nla_data(tb[TCA_TCINDEX_HASH]);
+		cp.hash = nla_get_u32(tb[TCA_TCINDEX_HASH]);
 	}
 
 	if (tb[TCA_TCINDEX_MASK]) {
 		if (nla_len(tb[TCA_TCINDEX_MASK]) < sizeof(u16))
 			goto errout;
-		cp.mask = *(u16 *) nla_data(tb[TCA_TCINDEX_MASK]);
+		cp.mask = nla_get_u16(tb[TCA_TCINDEX_MASK]);
 	}
 
 	if (tb[TCA_TCINDEX_SHIFT]) {
 		if (nla_len(tb[TCA_TCINDEX_SHIFT]) < sizeof(int))
 			goto errout;
-		cp.shift = *(int *) nla_data(tb[TCA_TCINDEX_SHIFT]);
+		cp.shift = nla_get_u32(tb[TCA_TCINDEX_SHIFT]);
 	}
 
 	err = -EBUSY;
@@ -251,8 +251,7 @@ tcindex_set_parms(struct tcf_proto *tp, unsigned long base, u32 handle,
 	if (tb[TCA_TCINDEX_FALL_THROUGH]) {
 		if (nla_len(tb[TCA_TCINDEX_FALL_THROUGH]) < sizeof(u32))
 			goto errout;
-		cp.fall_through =
-			*(u32 *) nla_data(tb[TCA_TCINDEX_FALL_THROUGH]);
+		cp.fall_through = nla_get_u32(tb[TCA_TCINDEX_FALL_THROUGH]);
 	}
 
 	if (!cp.hash) {
@@ -305,7 +304,7 @@ tcindex_set_parms(struct tcf_proto *tp, unsigned long base, u32 handle,
 	}
 
 	if (tb[TCA_TCINDEX_CLASSID]) {
-		cr.res.classid = *(u32 *) nla_data(tb[TCA_TCINDEX_CLASSID]);
+		cr.res.classid = nla_get_u32(tb[TCA_TCINDEX_CLASSID]);
 		tcf_bind_filter(tp, &cr.res, base);
 	}
 
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 326711e..a4e72e8 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -474,7 +474,7 @@ static int u32_set_parms(struct tcf_proto *tp, unsigned long base,
 
 	err = -EINVAL;
 	if (tb[TCA_U32_LINK]) {
-		u32 handle = *(u32*)nla_data(tb[TCA_U32_LINK]);
+		u32 handle = nla_get_u32(tb[TCA_U32_LINK]);
 		struct tc_u_hnode *ht_down = NULL;
 
 		if (TC_U32_KEY(handle))
@@ -496,7 +496,7 @@ static int u32_set_parms(struct tcf_proto *tp, unsigned long base,
 			ht_down->refcnt--;
 	}
 	if (tb[TCA_U32_CLASSID]) {
-		n->res.classid = *(u32*)nla_data(tb[TCA_U32_CLASSID]);
+		n->res.classid = nla_get_u32(tb[TCA_U32_CLASSID]);
 		tcf_bind_filter(tp, &n->res, base);
 	}
 
@@ -543,7 +543,7 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 	}
 
 	if (tb[TCA_U32_DIVISOR]) {
-		unsigned divisor = *(unsigned*)nla_data(tb[TCA_U32_DIVISOR]);
+		unsigned divisor = nla_get_u32(tb[TCA_U32_DIVISOR]);
 
 		if (--divisor > 0x100)
 			return -EINVAL;
@@ -569,7 +569,7 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 	}
 
 	if (tb[TCA_U32_HASH]) {
-		htid = *(unsigned*)nla_data(tb[TCA_U32_HASH]);
+		htid = nla_get_u32(tb[TCA_U32_HASH]);
 		if (TC_U32_HTID(htid) == TC_U32_ROOT) {
 			ht = tp->root;
 			htid = ht->handle;
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index 63ae6a2..d9f487d 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -600,7 +600,7 @@ static int meta_int_change(struct meta_value *dst, struct nlattr *nla)
 		dst->val = *(unsigned long *) nla_data(nla);
 		dst->len = sizeof(unsigned long);
 	} else if (nla_len(nla) == sizeof(u32)) {
-		dst->val = *(u32 *) nla_data(nla);
+		dst->val = nla_get_u32(nla);
 		dst->len = sizeof(u32);
 	} else
 		return -EINVAL;
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 4d87659..0c71f2e 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -231,7 +231,7 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 
 	if (!tb[TCA_ATM_FD] || nla_len(tb[TCA_ATM_FD]) < sizeof(fd))
 		return -EINVAL;
-	fd = *(int *)nla_data(tb[TCA_ATM_FD]);
+	fd = nla_get_u32(tb[TCA_ATM_FD]);
 	pr_debug("atm_tc_change: fd %d\n", fd);
 	if (tb[TCA_ATM_HDR]) {
 		hdr_len = nla_len(tb[TCA_ATM_HDR]);
@@ -246,7 +246,7 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 		if (nla_len(tb[TCA_ATM_EXCESS]) != sizeof(u32))
 			return -EINVAL;
 		excess = (struct atm_flow_data *)
-			atm_tc_get(sch, *(u32 *)nla_data(tb[TCA_ATM_EXCESS]));
+			atm_tc_get(sch, nla_get_u32(tb[TCA_ATM_EXCESS]));
 		if (!excess)
 			return -ENOENT;
 	}
