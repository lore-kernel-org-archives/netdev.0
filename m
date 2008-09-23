From: David Miller <davem@davemloft.net>
Subject: [PATCH]: net: Add skb_queue_is_last().
Date: Tue, 23 Sep 2008 00:36:01 -0700 (PDT)
Message-ID: <20080923.003601.243492100.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35499
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753498AbYIWHgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 03:36:13 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id ADD78C8C181
	for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 00:36:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


net: Add skb_queue_is_last().

Several bits of code want to know "is this the last SKB in
a queue", and all of them implement this by hand.

Provide an common interface to make this check.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/skbuff.h |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4a144e8..3a5838d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -473,6 +473,19 @@ static inline int skb_queue_empty(const struct sk_buff_head *list)
 }
 
 /**
+ *	skb_queue_is_last - check if skb is the last entry in the queue
+ *	@list: queue head
+ *	@skb: buffer
+ *
+ *	Returns true if @skb is the last buffer on the list.
+ */
+static inline bool skb_queue_is_last(const struct sk_buff_head *list,
+				     const struct sk_buff *skb)
+{
+	return (skb->next == (struct sk_buff *) list);
+}
+
+/**
  *	skb_get - reference buffer
  *	@skb: buffer to reference
  *
-- 
1.5.6.5

