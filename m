From: Jing Wang <windsdaemon@gmail.com>
Subject: [PATCH 1/1] net:sched  fix a bug about memery leak
Date: Thu, 24 Oct 2013 17:12:44 +0800
Message-ID: <1382605964-2693-1-git-send-email-windsdaemon@gmail.com>
Cc: Jing Wang <windsdaemon@gmail.com>
To: davem@davemloft.net, jhs@mojatatu.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36559 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754245Ab3JXJR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 05:17:56 -0400
Received: by mail-pa0-f47.google.com with SMTP id lf10so2193957pab.20
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 02:17:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jing Wang <windsdaemon@gmail.com>

the code isn't properly release memory

Signed-off-by: Jing Wang <windsdaemon@gmail.com>
---
 net/sched/cls_route.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 37da567..118f8d5 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -466,11 +466,11 @@ static int route4_change(struct net *net, struct sk_buff *in_skb,
 		goto reinsert;
 	}
 
-	err = -ENOBUFS;
+	err = -ENOMEM;
 	if (head == NULL) {
 		head = kzalloc(sizeof(struct route4_head), GFP_KERNEL);
 		if (head == NULL)
-			goto errout;
+			goto errhead;
 
 		tcf_tree_lock(tp);
 		tp->root = head;
@@ -479,7 +479,7 @@ static int route4_change(struct net *net, struct sk_buff *in_skb,
 
 	f = kzalloc(sizeof(struct route4_filter), GFP_KERNEL);
 	if (f == NULL)
-		goto errout;
+		goto errflt;
 
 	err = route4_set_parms(net, tp, base, f, handle, head, tb,
 		tca[TCA_RATE], 1);
@@ -517,6 +517,9 @@ reinsert:
 
 errout:
 	kfree(f);
+errflt:
+    kfree(head);
+errhead:
 	return err;
 }
 
-- 
1.7.1
