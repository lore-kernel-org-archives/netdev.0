From: David Miller <davem@davemloft.net>
Subject: [PATCH]: net: Add skb_queue_next().
Date: Tue, 23 Sep 2008 01:06:41 -0700 (PDT)
Message-ID: <20080923.010641.165183362.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52460
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751359AbYIWIGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 04:06:53 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 0DEBDC8C181
	for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 01:06:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


net: Add skb_queue_next().

A lot of code wants to iterate over an SKB queue at the top level using
it's own control structure and iterator scheme.

Provide skb_queue_next(), which is only valid to invoke if
skb_queue_is_last() returns false.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/skbuff.h |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 3a5838d..d2f1778 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -486,6 +486,24 @@ static inline bool skb_queue_is_last(const struct sk_buff_head *list,
 }
 
 /**
+ *	skb_queue_next - return the next packet in the queue
+ *	@list: queue head
+ *	@skb: current buffer
+ *
+ *	Return the next packet in @list after @skb.  It is only valid to
+ *	call this if skb_queue_is_last() evaluates to false.
+ */
+static inline struct sk_buff *skb_queue_next(const struct sk_buff_head *list,
+					     const struct sk_buff *skb)
+{
+	/* This BUG_ON may seem severe, but if we just return then we
+	 * are going to dereference garbage.
+	 */
+	BUG_ON(skb_queue_is_last(list, skb));
+	return skb->next;
+}
+
+/**
  *	skb_get - reference buffer
  *	@skb: buffer to reference
  *
-- 
1.5.6.5

