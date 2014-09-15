From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 5/5] net_sched: clean up tcindex_set_parms()
Date: Mon, 15 Sep 2014 14:06:50 -0700
Message-ID: <1410815210-6693-6-git-send-email-xiyou.wangcong@gmail.com>
References: <1410815210-6693-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: john.fastabend@gmail.com, "David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:60902 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758986AbaIOVHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:07:10 -0400
Received: by mail-pa0-f47.google.com with SMTP id ey11so7109554pad.34
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 14:07:10 -0700 (PDT)
In-Reply-To: <1410815210-6693-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can move the allocation down.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_tcindex.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 4ec99a6..688ab75 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -229,7 +229,6 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	struct tcindex_filter_result new_filter_result, *old_r = r;
 	struct tcindex_filter_result cr;
 	struct tcindex_data *cp, *oldp;
-	struct tcindex_filter *f = NULL; /* make gcc behave */
 	struct tcf_exts e;
 
 	tcf_exts_init(&e, TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
@@ -348,12 +347,6 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	else
 		r = tcindex_lookup(cp, handle) ? : &new_filter_result;
 
-	if (r == &new_filter_result) {
-		f = kzalloc(sizeof(*f), GFP_KERNEL);
-		if (!f)
-			goto errout_alloc;
-	}
-
 	if (tb[TCA_TCINDEX_CLASSID]) {
 		cr.res.classid = nla_get_u32(tb[TCA_TCINDEX_CLASSID]);
 		tcf_bind_filter(tp, &cr.res, base);
@@ -374,6 +367,11 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	if (r == &new_filter_result) {
 		struct tcindex_filter *nfp;
 		struct tcindex_filter __rcu **fp;
+		struct tcindex_filter *f;
+
+		f = kzalloc(sizeof(*f), GFP_KERNEL);
+		if (!f)
+			goto errout_alloc;
 
 		f->key = handle;
 		f->result = new_filter_result;
-- 
1.8.3.1
