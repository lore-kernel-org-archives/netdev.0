From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/6] net_sched: cls_bpf: remove unnecessary iteration and use passed arg
Date: Tue,  2 Dec 2014 18:00:32 +0100
Message-ID: <1417539636-12710-3-git-send-email-jiri@resnulli.us>
References: <1417539636-12710-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:64950 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831AbaLBRHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 12:07:35 -0500
Received: by mail-wi0-f169.google.com with SMTP id r20so30380184wiv.4
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 09:07:34 -0800 (PST)
In-Reply-To: <1417539636-12710-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/cls_bpf.c | 17 +++++------------
 1 file changed, 5 insertions(+), 12 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index eed49d1..cbfaf6f 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -109,19 +109,12 @@ static void __cls_bpf_delete_prog(struct rcu_head *rcu)
 
 static int cls_bpf_delete(struct tcf_proto *tp, unsigned long arg)
 {
-	struct cls_bpf_head *head = rtnl_dereference(tp->root);
-	struct cls_bpf_prog *prog, *todel = (struct cls_bpf_prog *) arg;
-
-	list_for_each_entry(prog, &head->plist, link) {
-		if (prog == todel) {
-			list_del_rcu(&prog->link);
-			tcf_unbind_filter(tp, &prog->res);
-			call_rcu(&prog->rcu, __cls_bpf_delete_prog);
-			return 0;
-		}
-	}
+	struct cls_bpf_prog *prog = (struct cls_bpf_prog *) arg;
 
-	return -ENOENT;
+	list_del_rcu(&prog->link);
+	tcf_unbind_filter(tp, &prog->res);
+	call_rcu(&prog->rcu, __cls_bpf_delete_prog);
+	return 0;
 }
 
 static void cls_bpf_destroy(struct tcf_proto *tp)
-- 
1.9.3
