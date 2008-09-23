From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Fix bug in skb list splicing.
Date: Mon, 22 Sep 2008 22:17:52 -0700 (PDT)
Message-ID: <20080922.221752.07789780.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56853
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751005AbYIWFSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 01:18:04 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 5CE1AC8C181
	for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 22:17:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We don't update the qlen correctly when 'head' is
non-empty.

net: Fix bus in SKB queue splicing interfaces.

Handle the case of head being non-empty, by adding list->qlen
to head->qlen instead of using direct assignment.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/skbuff.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 027b061..4a144e8 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -738,7 +738,7 @@ static inline void skb_queue_splice(const struct sk_buff_head *list,
 {
 	if (!skb_queue_empty(list)) {
 		__skb_queue_splice(list, (struct sk_buff *) head, head->next);
-		head->qlen = list->qlen;
+		head->qlen += list->qlen;
 	}
 }
 
@@ -754,7 +754,7 @@ static inline void skb_queue_splice_init(struct sk_buff_head *list,
 {
 	if (!skb_queue_empty(list)) {
 		__skb_queue_splice(list, (struct sk_buff *) head, head->next);
-		head->qlen = list->qlen;
+		head->qlen += list->qlen;
 		__skb_queue_head_init(list);
 	}
 }
@@ -769,7 +769,7 @@ static inline void skb_queue_splice_tail(const struct sk_buff_head *list,
 {
 	if (!skb_queue_empty(list)) {
 		__skb_queue_splice(list, head->prev, (struct sk_buff *) head);
-		head->qlen = list->qlen;
+		head->qlen += list->qlen;
 	}
 }
 
@@ -786,7 +786,7 @@ static inline void skb_queue_splice_tail_init(struct sk_buff_head *list,
 {
 	if (!skb_queue_empty(list)) {
 		__skb_queue_splice(list, head->prev, (struct sk_buff *) head);
-		head->qlen = list->qlen;
+		head->qlen += list->qlen;
 		__skb_queue_head_init(list);
 	}
 }
-- 
1.5.6.5

