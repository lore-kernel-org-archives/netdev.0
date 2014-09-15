From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 3/5] net_sched: fix suspicious RCU usage in tcindex_classify()
Date: Mon, 15 Sep 2014 14:06:48 -0700
Message-ID: <1410815210-6693-4-git-send-email-xiyou.wangcong@gmail.com>
References: <1410815210-6693-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: john.fastabend@gmail.com, "David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:50933 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757873AbaIOVHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:07:07 -0400
Received: by mail-pa0-f46.google.com with SMTP id kq14so7209631pab.33
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 14:07:06 -0700 (PDT)
In-Reply-To: <1410815210-6693-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following kernel warning:

[   44.805900] [ INFO: suspicious RCU usage. ]
[   44.808946] 3.17.0-rc4+ #610 Not tainted
[   44.811831] -------------------------------
[   44.814873] net/sched/cls_tcindex.c:84 suspicious rcu_dereference_check() usage!

Fixes: commit 331b72922c5f58d48fd ("net: sched: RCU cls_tcindex")
Cc: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_tcindex.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 16ec1ed..f276de5 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -81,7 +81,7 @@ tcindex_lookup(struct tcindex_data *p, u16 key)
 static int tcindex_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			    struct tcf_result *res)
 {
-	struct tcindex_data *p = rcu_dereference(tp->root);
+	struct tcindex_data *p = rcu_dereference_bh(tp->root);
 	struct tcindex_filter_result *f;
 	int key = (skb->tc_index & p->mask) >> p->shift;
 
-- 
1.8.3.1
