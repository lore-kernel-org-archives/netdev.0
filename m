From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net:  skb_orphan() changes
Date: Tue, 30 Jul 2013 16:11:15 -0700
Message-ID: <1375225875.10515.36.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:40711 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756106Ab3G3XLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 19:11:16 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc8so19303pbc.4
        for <netdev@vger.kernel.org>; Tue, 30 Jul 2013 16:11:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

It is illegal to set skb->sk without corresponding destructor.

Its therefore safe for skb_orphan() to not clear skb->sk if
skb->destructor is not set.

Also avoid clearing skb->destructor if already NULL.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/skbuff.h |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5afefa0..a95547a 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1805,10 +1805,11 @@ static inline void pskb_trim_unique(struct sk_buff *skb, unsigned int len)
  */
 static inline void skb_orphan(struct sk_buff *skb)
 {
-	if (skb->destructor)
+	if (skb->destructor) {
 		skb->destructor(skb);
-	skb->destructor = NULL;
-	skb->sk		= NULL;
+		skb->destructor = NULL;
+		skb->sk		= NULL;
+	}
 }
 
 /**
