From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: remove the first parameter from tcf_exts_destroy()
Date: Thu, 25 Sep 2014 10:26:37 -0700
Message-ID: <1411665997-11013-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: davem@davemloft.net, Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:49086 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752624AbaIYR0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 13:26:43 -0400
Received: by mail-pa0-f49.google.com with SMTP id lf10so11265207pab.8
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 10:26:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/pkt_cls.h   | 2 +-
 net/sched/cls_api.c     | 2 +-
 net/sched/cls_basic.c   | 4 ++--
 net/sched/cls_bpf.c     | 4 ++--
 net/sched/cls_cgroup.c  | 6 +++---
 net/sched/cls_flow.c    | 4 ++--
 net/sched/cls_fw.c      | 4 ++--
 net/sched/cls_route.c   | 4 ++--
 net/sched/cls_rsvp.h    | 4 ++--
 net/sched/cls_tcindex.c | 4 ++--
 net/sched/cls_u32.c     | 4 ++--
 11 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 6da46dc..73f9532 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -137,7 +137,7 @@ tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
 int tcf_exts_validate(struct net *net, struct tcf_proto *tp,
 		      struct nlattr **tb, struct nlattr *rate_tlv,
 		      struct tcf_exts *exts, bool ovr);
-void tcf_exts_destroy(struct tcf_proto *tp, struct tcf_exts *exts);
+void tcf_exts_destroy(struct tcf_exts *exts);
 void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
 		     struct tcf_exts *src);
 int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts);
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index e547efd..77147c8 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -496,7 +496,7 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	return skb->len;
 }
 
-void tcf_exts_destroy(struct tcf_proto *tp, struct tcf_exts *exts)
+void tcf_exts_destroy(struct tcf_exts *exts)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	tcf_action_destroy(&exts->actions, TCA_ACT_UNBIND);
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 1937298..fe20826 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -94,7 +94,7 @@ static void basic_delete_filter(struct rcu_head *head)
 	struct tcf_proto *tp = f->tp;
 
 	tcf_unbind_filter(tp, &f->res);
-	tcf_exts_destroy(tp, &f->exts);
+	tcf_exts_destroy(&f->exts);
 	tcf_em_tree_destroy(tp, &f->ematches);
 	kfree(f);
 }
@@ -161,7 +161,7 @@ static int basic_set_parms(struct net *net, struct tcf_proto *tp,
 
 	return 0;
 errout:
-	tcf_exts_destroy(tp, &e);
+	tcf_exts_destroy(&e);
 	return err;
 }
 
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 4e3f5bf..4318d06 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -93,7 +93,7 @@ static int cls_bpf_init(struct tcf_proto *tp)
 static void cls_bpf_delete_prog(struct tcf_proto *tp, struct cls_bpf_prog *prog)
 {
 	tcf_unbind_filter(tp, &prog->res);
-	tcf_exts_destroy(tp, &prog->exts);
+	tcf_exts_destroy(&prog->exts);
 
 	bpf_prog_destroy(prog->filter);
 
@@ -217,7 +217,7 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 errout_free:
 	kfree(bpf_ops);
 errout:
-	tcf_exts_destroy(tp, &exts);
+	tcf_exts_destroy(&exts);
 	return ret;
 }
 
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 15c34d4..3409f16 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -86,7 +86,7 @@ static void cls_cgroup_destroy_rcu(struct rcu_head *root)
 						    struct cls_cgroup_head,
 						    rcu);
 
-	tcf_exts_destroy(head->tp, &head->exts);
+	tcf_exts_destroy(&head->exts);
 	tcf_em_tree_destroy(head->tp, &head->ematches);
 	kfree(head);
 }
@@ -135,7 +135,7 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 
 	err = tcf_em_tree_validate(tp, tb[TCA_CGROUP_EMATCHES], &t);
 	if (err < 0) {
-		tcf_exts_destroy(tp, &e);
+		tcf_exts_destroy(&e);
 		goto errout;
 	}
 
@@ -156,7 +156,7 @@ static void cls_cgroup_destroy(struct tcf_proto *tp)
 	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
 
 	if (head) {
-		tcf_exts_destroy(tp, &head->exts);
+		tcf_exts_destroy(&head->exts);
 		tcf_em_tree_destroy(tp, &head->ematches);
 		RCU_INIT_POINTER(tp->root, NULL);
 		kfree_rcu(head, rcu);
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 95736fa..f18d27f7 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -354,7 +354,7 @@ static void flow_destroy_filter(struct rcu_head *head)
 	struct flow_filter *f = container_of(head, struct flow_filter, rcu);
 
 	del_timer_sync(&f->perturb_timer);
-	tcf_exts_destroy(f->tp, &f->exts);
+	tcf_exts_destroy(&f->exts);
 	tcf_em_tree_destroy(f->tp, &f->ematches);
 	kfree(f);
 }
@@ -533,7 +533,7 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 	tcf_em_tree_destroy(tp, &t);
 	kfree(fnew);
 err1:
-	tcf_exts_destroy(tp, &e);
+	tcf_exts_destroy(&e);
 	return err;
 }
 
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 2650285..da805ae 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -126,7 +126,7 @@ static void fw_delete_filter(struct rcu_head *head)
 	struct tcf_proto *tp = f->tp;
 
 	tcf_unbind_filter(tp, &f->res);
-	tcf_exts_destroy(tp, &f->exts);
+	tcf_exts_destroy(&f->exts);
 	kfree(f);
 }
 
@@ -223,7 +223,7 @@ fw_change_attrs(struct net *net, struct tcf_proto *tp, struct fw_filter *f,
 
 	return 0;
 errout:
-	tcf_exts_destroy(tp, &e);
+	tcf_exts_destroy(&e);
 	return err;
 }
 
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index ba96dea..b665aee 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -272,7 +272,7 @@ route4_delete_filter(struct rcu_head *head)
 	struct tcf_proto *tp = f->tp;
 
 	tcf_unbind_filter(tp, &f->res);
-	tcf_exts_destroy(tp, &f->exts);
+	tcf_exts_destroy(&f->exts);
 	kfree(f);
 }
 
@@ -456,7 +456,7 @@ static int route4_set_parms(struct net *net, struct tcf_proto *tp,
 
 	return 0;
 errout:
-	tcf_exts_destroy(tp, &e);
+	tcf_exts_destroy(&e);
 	return err;
 }
 
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index b044c20..1c64a09 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -264,7 +264,7 @@ static void
 rsvp_delete_filter(struct tcf_proto *tp, struct rsvp_filter *f)
 {
 	tcf_unbind_filter(tp, &f->res);
-	tcf_exts_destroy(tp, &f->exts);
+	tcf_exts_destroy(&f->exts);
 	kfree_rcu(f, rcu);
 }
 
@@ -577,7 +577,7 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 errout:
 	kfree(f);
 errout2:
-	tcf_exts_destroy(tp, &e);
+	tcf_exts_destroy(&e);
 	return err;
 }
 
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 5054fae..e3c6fa3 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -169,7 +169,7 @@ tcindex_delete(struct tcf_proto *tp, unsigned long arg)
 		rcu_assign_pointer(*walk, rtnl_dereference(f->next));
 	}
 	tcf_unbind_filter(tp, &r->res);
-	tcf_exts_destroy(tp, &r->exts);
+	tcf_exts_destroy(&r->exts);
 	if (f)
 		kfree_rcu(f, rcu);
 	return 0;
@@ -401,7 +401,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 		kfree(cp->h);
 errout:
 	kfree(cp);
-	tcf_exts_destroy(tp, &e);
+	tcf_exts_destroy(&e);
 	return err;
 }
 
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index ef97a64..4be3ebf 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -359,7 +359,7 @@ static int u32_destroy_key(struct tcf_proto *tp,
 			   bool free_pf)
 {
 	tcf_unbind_filter(tp, &n->res);
-	tcf_exts_destroy(tp, &n->exts);
+	tcf_exts_destroy(&n->exts);
 	if (n->ht_down)
 		n->ht_down->refcnt--;
 #ifdef CONFIG_CLS_U32_PERF
@@ -606,7 +606,7 @@ static int u32_set_parms(struct net *net, struct tcf_proto *tp,
 
 	return 0;
 errout:
-	tcf_exts_destroy(tp, &e);
+	tcf_exts_destroy(&e);
 	return err;
 }
 
-- 
1.8.3.1
