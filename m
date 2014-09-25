From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 1/2] net_sched: fix errno in tcindex_set_parms()
Date: Thu, 25 Sep 2014 12:06:04 -0700
Message-ID: <1411671965-18887-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: davem@davemloft.net, Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:62541 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895AbaIYTGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 15:06:16 -0400
Received: by mail-pd0-f176.google.com with SMTP id z10so9872861pdj.35
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 12:06:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When kmemdup() fails, we should return -ENOMEM.

Cc: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_tcindex.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 5054fae..9d78fd7 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -237,15 +237,14 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	if (err < 0)
 		return err;
 
+	err = -ENOMEM;
 	/* tcindex_data attributes must look atomic to classifier/lookup so
 	 * allocate new tcindex data and RCU assign it onto root. Keeping
 	 * perfect hash and hash pointers from old data.
 	 */
 	cp = kzalloc(sizeof(*cp), GFP_KERNEL);
-	if (!cp) {
-		err = -ENOMEM;
+	if (!cp)
 		goto errout;
-	}
 
 	cp->mask = p->mask;
 	cp->shift = p->shift;
-- 
1.8.3.1
