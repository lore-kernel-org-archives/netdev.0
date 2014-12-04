From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] net: sched: cls: remove unused op put from tcf_proto_ops
Date: Thu,  4 Dec 2014 21:41:18 +0100
Message-ID: <1417725678-24968-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:60479 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbaLDUlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 15:41:21 -0500
Received: by mail-wi0-f169.google.com with SMTP id r20so37448130wiv.2
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 12:41:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is never called and implementations are void. So just remove it.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/sch_generic.h | 1 -
 net/sched/cls_basic.c     | 5 -----
 net/sched/cls_bpf.c       | 5 -----
 net/sched/cls_cgroup.c    | 5 -----
 net/sched/cls_flow.c      | 5 -----
 net/sched/cls_fw.c        | 5 -----
 net/sched/cls_route.c     | 5 -----
 net/sched/cls_rsvp.h      | 5 -----
 net/sched/cls_tcindex.c   | 8 --------
 net/sched/cls_u32.c       | 5 -----
 10 files changed, 49 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index d17ed6f..3d282cb 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -219,7 +219,6 @@ struct tcf_proto_ops {
 	void			(*destroy)(struct tcf_proto*);
 
 	unsigned long		(*get)(struct tcf_proto*, u32 handle);
-	void			(*put)(struct tcf_proto*, unsigned long);
 	int			(*change)(struct net *net, struct sk_buff *,
 					struct tcf_proto*, unsigned long,
 					u32 handle, struct nlattr **,
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 1c122c7..7cf0a62 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -72,10 +72,6 @@ static unsigned long basic_get(struct tcf_proto *tp, u32 handle)
 	return l;
 }
 
-static void basic_put(struct tcf_proto *tp, unsigned long f)
-{
-}
-
 static int basic_init(struct tcf_proto *tp)
 {
 	struct basic_head *head;
@@ -287,7 +283,6 @@ static struct tcf_proto_ops cls_basic_ops __read_mostly = {
 	.init		=	basic_init,
 	.destroy	=	basic_destroy,
 	.get		=	basic_get,
-	.put		=	basic_put,
 	.change		=	basic_change,
 	.delete		=	basic_delete,
 	.walk		=	basic_walk,
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index d0de979..84c8219 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -151,10 +151,6 @@ static unsigned long cls_bpf_get(struct tcf_proto *tp, u32 handle)
 	return ret;
 }
 
-static void cls_bpf_put(struct tcf_proto *tp, unsigned long f)
-{
-}
-
 static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 				   struct cls_bpf_prog *prog,
 				   unsigned long base, struct nlattr **tb,
@@ -356,7 +352,6 @@ static struct tcf_proto_ops cls_bpf_ops __read_mostly = {
 	.init		=	cls_bpf_init,
 	.destroy	=	cls_bpf_destroy,
 	.get		=	cls_bpf_get,
-	.put		=	cls_bpf_put,
 	.change		=	cls_bpf_change,
 	.delete		=	cls_bpf_delete,
 	.walk		=	cls_bpf_walk,
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index dbee65e..741bfa7 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -67,10 +67,6 @@ static unsigned long cls_cgroup_get(struct tcf_proto *tp, u32 handle)
 	return 0UL;
 }
 
-static void cls_cgroup_put(struct tcf_proto *tp, unsigned long f)
-{
-}
-
 static int cls_cgroup_init(struct tcf_proto *tp)
 {
 	return 0;
@@ -213,7 +209,6 @@ static struct tcf_proto_ops cls_cgroup_ops __read_mostly = {
 	.classify	=	cls_cgroup_classify,
 	.destroy	=	cls_cgroup_destroy,
 	.get		=	cls_cgroup_get,
-	.put		=	cls_cgroup_put,
 	.delete		=	cls_cgroup_delete,
 	.walk		=	cls_cgroup_walk,
 	.dump		=	cls_cgroup_dump,
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 819c230..8e22718 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -581,10 +581,6 @@ static unsigned long flow_get(struct tcf_proto *tp, u32 handle)
 	return 0;
 }
 
-static void flow_put(struct tcf_proto *tp, unsigned long f)
-{
-}
-
 static int flow_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		     struct sk_buff *skb, struct tcmsg *t)
 {
@@ -671,7 +667,6 @@ static struct tcf_proto_ops cls_flow_ops __read_mostly = {
 	.change		= flow_change,
 	.delete		= flow_delete,
 	.get		= flow_get,
-	.put		= flow_put,
 	.dump		= flow_dump,
 	.walk		= flow_walk,
 	.owner		= THIS_MODULE,
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index dbfdfd1..23fda2a 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -111,10 +111,6 @@ static unsigned long fw_get(struct tcf_proto *tp, u32 handle)
 	return 0;
 }
 
-static void fw_put(struct tcf_proto *tp, unsigned long f)
-{
-}
-
 static int fw_init(struct tcf_proto *tp)
 {
 	return 0;
@@ -411,7 +407,6 @@ static struct tcf_proto_ops cls_fw_ops __read_mostly = {
 	.init		=	fw_init,
 	.destroy	=	fw_destroy,
 	.get		=	fw_get,
-	.put		=	fw_put,
 	.change		=	fw_change,
 	.delete		=	fw_delete,
 	.walk		=	fw_walk,
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 109a329..098a273 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -256,10 +256,6 @@ static unsigned long route4_get(struct tcf_proto *tp, u32 handle)
 	return 0;
 }
 
-static void route4_put(struct tcf_proto *tp, unsigned long f)
-{
-}
-
 static int route4_init(struct tcf_proto *tp)
 {
 	return 0;
@@ -649,7 +645,6 @@ static struct tcf_proto_ops cls_route4_ops __read_mostly = {
 	.init		=	route4_init,
 	.destroy	=	route4_destroy,
 	.get		=	route4_get,
-	.put		=	route4_put,
 	.change		=	route4_change,
 	.delete		=	route4_delete,
 	.walk		=	route4_walk,
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 6bb55f2..b7af362 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -271,10 +271,6 @@ static unsigned long rsvp_get(struct tcf_proto *tp, u32 handle)
 	return 0;
 }
 
-static void rsvp_put(struct tcf_proto *tp, unsigned long f)
-{
-}
-
 static int rsvp_init(struct tcf_proto *tp)
 {
 	struct rsvp_head *data;
@@ -708,7 +704,6 @@ static struct tcf_proto_ops RSVP_OPS __read_mostly = {
 	.init		=	rsvp_init,
 	.destroy	=	rsvp_destroy,
 	.get		=	rsvp_get,
-	.put		=	rsvp_put,
 	.change		=	rsvp_change,
 	.delete		=	rsvp_delete,
 	.walk		=	rsvp_walk,
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 30f10fb..0d9d891 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -116,13 +116,6 @@ static unsigned long tcindex_get(struct tcf_proto *tp, u32 handle)
 	return r && tcindex_filter_is_set(r) ? (unsigned long) r : 0UL;
 }
 
-
-static void tcindex_put(struct tcf_proto *tp, unsigned long f)
-{
-	pr_debug("tcindex_put(tp %p,f 0x%lx)\n", tp, f);
-}
-
-
 static int tcindex_init(struct tcf_proto *tp)
 {
 	struct tcindex_data *p;
@@ -560,7 +553,6 @@ static struct tcf_proto_ops cls_tcindex_ops __read_mostly = {
 	.init		=	tcindex_init,
 	.destroy	=	tcindex_destroy,
 	.get		=	tcindex_get,
-	.put		=	tcindex_put,
 	.change		=	tcindex_change,
 	.delete		=	tcindex_delete,
 	.walk		=	tcindex_walk,
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 0472909..09487af 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -299,10 +299,6 @@ static unsigned long u32_get(struct tcf_proto *tp, u32 handle)
 	return (unsigned long)u32_lookup_key(ht, handle);
 }
 
-static void u32_put(struct tcf_proto *tp, unsigned long f)
-{
-}
-
 static u32 gen_new_htid(struct tc_u_common *tp_c)
 {
 	int i = 0x800;
@@ -1021,7 +1017,6 @@ static struct tcf_proto_ops cls_u32_ops __read_mostly = {
 	.init		=	u32_init,
 	.destroy	=	u32_destroy,
 	.get		=	u32_get,
-	.put		=	u32_put,
 	.change		=	u32_change,
 	.delete		=	u32_delete,
 	.walk		=	u32_walk,
-- 
1.9.3
