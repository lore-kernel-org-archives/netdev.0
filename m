From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 4/4] [SKB]: __skb_queue_tail = __skb_insert before
Date: Mon, 14 Apr 2008 07:11:10 +0100
Message-ID: <1208153470-9847-5-git-send-email-gerrit@erg.abdn.ac.uk>
References: <skbuff_h_small_patchset>
 <1208153470-9847-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1208153470-9847-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1208153470-9847-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1208153470-9847-4-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:35085 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753647AbYDNGLS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 02:11:18 -0400
In-Reply-To: <1208153470-9847-4-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This expresses __skb_queue_tail() in terms of __skb_insert(),
using __skb_insert_before() as auxiliary function.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/skbuff.h |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -694,6 +694,13 @@ static inline void __skb_queue_after(str
 extern void skb_append(struct sk_buff *old, struct sk_buff *newsk,
 		       struct sk_buff_head *list);
 
+static inline void __skb_queue_before(struct sk_buff_head *list,
+				      struct sk_buff *next,
+				      struct sk_buff *newsk)
+{
+	__skb_insert(newsk, next->prev, next, list);
+}
+
 /**
  *	__skb_queue_head - queue a buffer at the list head
  *	@list: list to use
@@ -725,14 +732,7 @@ extern void skb_queue_tail(struct sk_buf
 static inline void __skb_queue_tail(struct sk_buff_head *list,
 				   struct sk_buff *newsk)
 {
-	struct sk_buff *prev, *next;
-
-	list->qlen++;
-	next = (struct sk_buff *)list;
-	prev = next->prev;
-	newsk->next = next;
-	newsk->prev = prev;
-	next->prev  = prev->next = newsk;
+	__skb_queue_before(list, (struct sk_buff *)list, newsk);
 }
 
 /*


The University of Aberdeen is a charity registered in Scotland, No SC013683.

