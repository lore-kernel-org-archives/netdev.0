From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/6] net_sched: cls_basic: remove unnecessary iteration and use passed arg
Date: Tue,  2 Dec 2014 18:00:31 +0100
Message-ID: <1417539636-12710-2-git-send-email-jiri@resnulli.us>
References: <1417539636-12710-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:56697 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932815AbaLBRAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 12:00:43 -0500
Received: by mail-wg0-f45.google.com with SMTP id b13so17596440wgh.4
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 09:00:42 -0800 (PST)
In-Reply-To: <1417539636-12710-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/cls_basic.c | 16 +++++-----------
 1 file changed, 5 insertions(+), 11 deletions(-)

diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index cd61280..1c122c7 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -113,18 +113,12 @@ static void basic_destroy(struct tcf_proto *tp)
 
 static int basic_delete(struct tcf_proto *tp, unsigned long arg)
 {
-	struct basic_head *head = rtnl_dereference(tp->root);
-	struct basic_filter *t, *f = (struct basic_filter *) arg;
-
-	list_for_each_entry(t, &head->flist, link)
-		if (t == f) {
-			list_del_rcu(&t->link);
-			tcf_unbind_filter(tp, &t->res);
-			call_rcu(&t->rcu, basic_delete_filter);
-			return 0;
-		}
+	struct basic_filter *f = (struct basic_filter *) arg;
 
-	return -ENOENT;
+	list_del_rcu(&f->link);
+	tcf_unbind_filter(tp, &f->res);
+	call_rcu(&f->rcu, basic_delete_filter);
+	return 0;
 }
 
 static const struct nla_policy basic_policy[TCA_BASIC_MAX + 1] = {
-- 
1.9.3
