From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 1/5] net_sched: fix an allocation bug in tcindex_set_parms()
Date: Mon, 15 Sep 2014 14:06:46 -0700
Message-ID: <1410815210-6693-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1410815210-6693-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: john.fastabend@gmail.com, "David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:38369 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758976AbaIOVHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:07:06 -0400
Received: by mail-pa0-f46.google.com with SMTP id kq14so7163591pab.19
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 14:07:06 -0700 (PDT)
In-Reply-To: <1410815210-6693-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: commit 331b72922c5f58d48fd ("net: sched: RCU cls_tcindex")
Cc: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_tcindex.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index a9f4279..a02ca72 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -241,7 +241,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	 * allocate new tcindex data and RCU assign it onto root. Keeping
 	 * perfect hash and hash pointers from old data.
 	 */
-	cp = kzalloc(sizeof(cp), GFP_KERNEL);
+	cp = kzalloc(sizeof(*cp), GFP_KERNEL);
 	if (!cp)
 		return -ENOMEM;
 
-- 
1.8.3.1
