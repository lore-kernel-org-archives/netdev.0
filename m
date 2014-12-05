From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] net: sched: cls: use nla_nest_cancel instead of nlmsg_trim
Date: Fri,  5 Dec 2014 15:50:23 +0100
Message-ID: <1417791023-28124-2-git-send-email-jiri@resnulli.us>
References: <1417791023-28124-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:62333 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbaLEOu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 09:50:27 -0500
Received: by mail-wi0-f172.google.com with SMTP id n3so1659931wiv.5
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 06:50:25 -0800 (PST)
In-Reply-To: <1417791023-28124-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To cancel nesting, this function is more convenient.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/cls_cgroup.c  | 3 +--
 net/sched/cls_flow.c    | 2 +-
 net/sched/cls_fw.c      | 3 +--
 net/sched/cls_route.c   | 3 +--
 net/sched/cls_rsvp.h    | 3 +--
 net/sched/cls_tcindex.c | 3 +--
 6 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 741bfa7..221697a 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -177,7 +177,6 @@ static int cls_cgroup_dump(struct net *net, struct tcf_proto *tp, unsigned long
 			   struct sk_buff *skb, struct tcmsg *t)
 {
 	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
-	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
 
 	t->tcm_handle = head->handle;
@@ -198,7 +197,7 @@ static int cls_cgroup_dump(struct net *net, struct tcf_proto *tp, unsigned long
 	return skb->len;
 
 nla_put_failure:
-	nlmsg_trim(skb, b);
+	nla_nest_cancel(skb, nest);
 	return -1;
 }
 
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 8e22718..15d68f2 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -638,7 +638,7 @@ static int flow_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 	return skb->len;
 
 nla_put_failure:
-	nlmsg_trim(skb, nest);
+	nla_nest_cancel(skb, nest);
 	return -1;
 }
 
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 23fda2a..a5269f7 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -356,7 +356,6 @@ static int fw_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 {
 	struct fw_head *head = rtnl_dereference(tp->root);
 	struct fw_filter *f = (struct fw_filter *)fh;
-	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
 
 	if (f == NULL)
@@ -397,7 +396,7 @@ static int fw_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 	return skb->len;
 
 nla_put_failure:
-	nlmsg_trim(skb, b);
+	nla_nest_cancel(skb, nest);
 	return -1;
 }
 
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 098a273..2ecd246 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -593,7 +593,6 @@ static int route4_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		       struct sk_buff *skb, struct tcmsg *t)
 {
 	struct route4_filter *f = (struct route4_filter *)fh;
-	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
 	u32 id;
 
@@ -635,7 +634,7 @@ static int route4_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 	return skb->len;
 
 nla_put_failure:
-	nlmsg_trim(skb, b);
+	nla_nest_cancel(skb, nest);
 	return -1;
 }
 
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index b7af362..edd8ade 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -653,7 +653,6 @@ static int rsvp_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 {
 	struct rsvp_filter *f = (struct rsvp_filter *)fh;
 	struct rsvp_session *s;
-	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
 	struct tc_rsvp_pinfo pinfo;
 
@@ -694,7 +693,7 @@ static int rsvp_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 	return skb->len;
 
 nla_put_failure:
-	nlmsg_trim(skb, b);
+	nla_nest_cancel(skb, nest);
 	return -1;
 }
 
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 0d9d891..48d5e7b 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -489,7 +489,6 @@ static int tcindex_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 {
 	struct tcindex_data *p = rtnl_dereference(tp->root);
 	struct tcindex_filter_result *r = (struct tcindex_filter_result *) fh;
-	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
 
 	pr_debug("tcindex_dump(tp %p,fh 0x%lx,skb %p,t %p),p %p,r %p,b %p\n",
@@ -543,7 +542,7 @@ static int tcindex_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 	return skb->len;
 
 nla_put_failure:
-	nlmsg_trim(skb, b);
+	nla_nest_cancel(skb, nest);
 	return -1;
 }
 
-- 
1.9.3
