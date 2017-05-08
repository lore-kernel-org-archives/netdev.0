From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH net] ipv6: make sure dev is not NULL before call ip6_frag_reasm
Date: Mon,  8 May 2017 11:09:24 +0800
Message-ID: <1494212964-17861-1-git-send-email-liuhangbin@gmail.com>
Cc: Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36549 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751710AbdEHDJw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 7 May 2017 23:09:52 -0400
Received: by mail-pf0-f194.google.com with SMTP id v14so8050616pfd.3
        for <netdev@vger.kernel.org>; Sun, 07 May 2017 20:09:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since ip6_frag_reasm() will call __in6_dev_get(dev), which will access
dev->ip6_ptr. We need to make sure dev is not NULL.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 net/ipv6/reassembly.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index e1da5b8..e3ebd62 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -348,7 +348,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 		fq->q.flags |= INET_FRAG_FIRST_IN;
 	}
 
-	if (fq->q.flags == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
+	if (dev && fq->q.flags == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
 	    fq->q.meat == fq->q.len) {
 		int res;
 		unsigned long orefdst = skb->_skb_refdst;
-- 
2.5.5
