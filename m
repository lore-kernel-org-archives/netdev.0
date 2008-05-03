From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] [NET] fix useless comment reference loop
Date: Sun, 04 May 2008 00:05:42 +0200
Message-ID: <1209852342.3673.16.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:51119 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754711AbYECWFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2008 18:05:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

include/linux/skbuff.h says:
        /* These elements must be at the end, see alloc_skb() for details.  */

net/core/skbuff.c says:
	* See comment in sk_buff definition, just before the 'tail' member

This patch contains my guess as to the actual reason rather than a
dead comment reference loop.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
Not that it probably makes much of a difference anyway.

 net/core/skbuff.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- everything.orig/net/core/skbuff.c	2008-05-04 00:01:25.000000000 +0200
+++ everything/net/core/skbuff.c	2008-05-04 00:02:41.000000000 +0200
@@ -206,7 +206,9 @@ struct sk_buff *__alloc_skb(unsigned int
 		goto nodata;
 
 	/*
-	 * See comment in sk_buff definition, just before the 'tail' member
+	 * Only clear those fields we need to clear, not those that we will
+	 * actually initialise below. Hence, don't put any more fields after
+	 * the tail pointer in struct sk_buff!
 	 */
 	memset(skb, 0, offsetof(struct sk_buff, tail));
 	skb->truesize = size + sizeof(struct sk_buff);


