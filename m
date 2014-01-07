From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: skbuff: const-ify casts in skb_queue_* functions
Date: Tue,  7 Jan 2014 23:23:44 +0100
Message-ID: <1389133424-11176-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41787 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753627AbaAGWXq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 17:23:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should const-ify comparisons on skb_queue_* inline helper
functions as their parameters are const as well, so lets not
drop that.

Suggested-by: Brad Spengler <spender@grsecurity.net>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/linux/skbuff.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 956e11a..d97f2d0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -827,7 +827,7 @@ static inline struct skb_shared_hwtstamps *skb_hwtstamps(struct sk_buff *skb)
  */
 static inline int skb_queue_empty(const struct sk_buff_head *list)
 {
-	return list->next == (struct sk_buff *)list;
+	return list->next == (const struct sk_buff *) list;
 }
 
 /**
@@ -840,7 +840,7 @@ static inline int skb_queue_empty(const struct sk_buff_head *list)
 static inline bool skb_queue_is_last(const struct sk_buff_head *list,
 				     const struct sk_buff *skb)
 {
-	return skb->next == (struct sk_buff *)list;
+	return skb->next == (const struct sk_buff *) list;
 }
 
 /**
@@ -853,7 +853,7 @@ static inline bool skb_queue_is_last(const struct sk_buff_head *list,
 static inline bool skb_queue_is_first(const struct sk_buff_head *list,
 				      const struct sk_buff *skb)
 {
-	return skb->prev == (struct sk_buff *)list;
+	return skb->prev == (const struct sk_buff *) list;
 }
 
 /**
-- 
1.7.11.7
