From: roy.qing.li@gmail.com
Subject: [PATCH net-next] skbuff: update sk truesize in pskb_expand_head
Date: Fri, 14 Oct 2011 15:39:30 +0800
Message-ID: <1318577970-19566-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60140 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753918Ab1JNHjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 03:39:45 -0400
Received: by wwf22 with SMTP id 22so3019174wwf.1
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 00:39:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when pskb_expand_head reallocates header of &sk_buff, the sk
truesize should be updated simultaneously

Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
---
 net/core/skbuff.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 387703f..48e0be9 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -920,6 +920,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	}
 	off = (data + nhead) - skb->head;
 
+	skb->truesize += (size - (skb_end_pointer(skb) - skb->head));
 	skb->head     = data;
 adjust_others:
 	skb->data    += off;
-- 
1.7.1
