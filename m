From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: skb_peek()/skb_peek_tail() cleanups
Date: Tue, 01 May 2012 04:31:46 +0200
Message-ID: <1335839506.11396.17.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:54964 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752527Ab2EACbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 22:31:52 -0400
Received: by wejx9 with SMTP id x9so2149903wej.19
        for <netdev@vger.kernel.org>; Mon, 30 Apr 2012 19:31:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

remove useless casts and rename variables for less confusion.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/skbuff.h |   20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2c75e98..988fc49 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -883,10 +883,11 @@ static inline struct sk_buff *skb_unshare(struct sk_buff *skb,
  */
 static inline struct sk_buff *skb_peek(const struct sk_buff_head *list_)
 {
-	struct sk_buff *list = ((const struct sk_buff *)list_)->next;
-	if (list == (struct sk_buff *)list_)
-		list = NULL;
-	return list;
+	struct sk_buff *skb = list_->next;
+
+	if (skb == (struct sk_buff *)list_)
+		skb = NULL;
+	return skb;
 }
 
 /**
@@ -902,6 +903,7 @@ static inline struct sk_buff *skb_peek_next(struct sk_buff *skb,
 		const struct sk_buff_head *list_)
 {
 	struct sk_buff *next = skb->next;
+
 	if (next == (struct sk_buff *)list_)
 		next = NULL;
 	return next;
@@ -922,10 +924,12 @@ static inline struct sk_buff *skb_peek_next(struct sk_buff *skb,
  */
 static inline struct sk_buff *skb_peek_tail(const struct sk_buff_head *list_)
 {
-	struct sk_buff *list = ((const struct sk_buff *)list_)->prev;
-	if (list == (struct sk_buff *)list_)
-		list = NULL;
-	return list;
+	struct sk_buff *skb = list_->prev;
+
+	if (skb == (struct sk_buff *)list_)
+		skb = NULL;
+	return skb;
+
 }
 
 /**
