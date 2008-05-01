From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] [NET] print skb pointer in truesize bug
Date: Thu, 01 May 2008 13:00:56 +0200
Message-ID: <1209639656.7067.2.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:37610 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754878AbYEALBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 07:01:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While debugging the mac80211 truesize problem I always wished
that I knew exactly which skb showed the problem, this makes
skb_truesize_bug() print out the pointer.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 net/core/skbuff.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- everything.orig/net/core/skbuff.c	2008-05-01 12:53:09.000000000 +0200
+++ everything/net/core/skbuff.c	2008-05-01 12:53:31.000000000 +0200
@@ -152,8 +152,8 @@ void skb_under_panic(struct sk_buff *skb
 void skb_truesize_bug(struct sk_buff *skb)
 {
 	printk(KERN_ERR "SKB BUG: Invalid truesize (%u) "
-	       "len=%u, sizeof(sk_buff)=%Zd\n",
-	       skb->truesize, skb->len, sizeof(struct sk_buff));
+	       "len=%u, sizeof(sk_buff)=%Zd, skb=0x%p\n",
+	       skb->truesize, skb->len, sizeof(struct sk_buff), skb);
 }
 EXPORT_SYMBOL(skb_truesize_bug);
 


