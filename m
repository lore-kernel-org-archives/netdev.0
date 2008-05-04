From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC/T] [NET] make pskb_expand_head warn when called with invalid
	state
Date: Sun, 04 May 2008 20:16:02 +0200
Message-ID: <1209924962.3655.8.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:34087 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752641AbYEDSQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 14:16:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes pskb_expand_head warn when called when a socket is attached.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
Based on a different patch by davem.

Will also trigger with mac80211.

 net/core/skbuff.c |    2 ++
 1 file changed, 2 insertions(+)

--- everything.orig/net/core/skbuff.c	2008-05-04 01:18:49.000000000 +0200
+++ everything/net/core/skbuff.c	2008-05-04 01:23:50.000000000 +0200
@@ -689,6 +689,8 @@ int pskb_expand_head(struct sk_buff *skb
 	if (!data)
 		goto nodata;
 
+	WARN_ON((nhead || ntail) && skb->sk);
+
 	/* Copy only real data... and, alas, header. This should be
 	 * optimized for the cases when header is void. */
 #ifdef NET_SKBUFF_DATA_USES_OFFSET


