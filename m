From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 2/2] net_sched: fix another regression in cls_tcindex
Date: Thu, 25 Sep 2014 12:06:05 -0700
Message-ID: <1411671965-18887-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1411671965-18887-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: davem@davemloft.net, Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:65182 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895AbaIYTGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 15:06:17 -0400
Received: by mail-pa0-f53.google.com with SMTP id hz1so11691281pad.40
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 12:06:17 -0700 (PDT)
In-Reply-To: <1411671965-18887-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clearly the following change is not expected:

	-       if (!cp.perfect && !cp.h)
	-               cp.alloc_hash = cp.hash;
	+       if (!cp->perfect && cp->h)
	+               cp->alloc_hash = cp->hash;

Fixes: commit 331b72922c5f58d48fd ("net: sched: RCU cls_tcindex")
Cc: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_tcindex.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 9d78fd7..a18eb1b 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -303,7 +303,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 			cp->hash = DEFAULT_HASH_SIZE;
 	}
 
-	if (!cp->perfect && cp->h)
+	if (!cp->perfect && !cp->h)
 		cp->alloc_hash = cp->hash;
 
 	/* Note: this could be as restrictive as if (handle & ~(mask >> shift))
-- 
1.8.3.1
