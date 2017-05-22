From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] net: sched: cls_matchall: fix null pointer dereference
Date: Mon, 22 May 2017 16:46:13 +0200
Message-ID: <20170522144613.22848-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, colin.king@canonical.com, yotamg@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33052 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935040AbdEVOqQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 10:46:16 -0400
Received: by mail-wr0-f194.google.com with SMTP id w50so7182756wrc.0
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 07:46:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Since the head is guaranteed by the check above to be null, the call_rcu
would explode. Remove the previously logically dead code that was made
logically very much alive and kicking.

Fixes: 985538eee06f ("net/sched: remove redundant null check on head")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_matchall.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index dee469f..51859b8 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -203,7 +203,6 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
 
 	*arg = (unsigned long) head;
 	rcu_assign_pointer(tp->root, new);
-	call_rcu(&head->rcu, mall_destroy_rcu);
 	return 0;
 
 err_replace_hw_filter:
-- 
2.9.3
