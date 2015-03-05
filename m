From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: move tp->root allocation into route4_init()
Date: Wed,  4 Mar 2015 20:11:43 -0800
Message-ID: <1425528704-21646-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:46553 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbbCEEL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 23:11:58 -0500
Received: by pdev10 with SMTP id v10so2553628pde.13
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 20:11:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_route.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 2ecd246..bb8a602 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -258,6 +258,13 @@ static unsigned long route4_get(struct tcf_proto *tp, u32 handle)
 
 static int route4_init(struct tcf_proto *tp)
 {
+	struct route4_head *head;
+
+	head = kzalloc(sizeof(struct route4_head), GFP_KERNEL);
+	if (head == NULL)
+		return -ENOBUFS;
+
+	rcu_assign_pointer(tp->root, head);
 	return 0;
 }
 
@@ -484,13 +491,6 @@ static int route4_change(struct net *net, struct sk_buff *in_skb,
 			return -EINVAL;
 
 	err = -ENOBUFS;
-	if (head == NULL) {
-		head = kzalloc(sizeof(struct route4_head), GFP_KERNEL);
-		if (head == NULL)
-			goto errout;
-		rcu_assign_pointer(tp->root, head);
-	}
-
 	f = kzalloc(sizeof(struct route4_filter), GFP_KERNEL);
 	if (!f)
 		goto errout;
-- 
1.8.1.4
