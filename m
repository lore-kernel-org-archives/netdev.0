From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 3/6] skb: Add skb_peek_next helper
Date: Tue, 21 Feb 2012 21:31:18 +0400
Message-ID: <4F43D4E6.4060206@parallels.com>
References: <4F43D49E.3010401@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:28444 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753439Ab2BURb0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Feb 2012 12:31:26 -0500
In-Reply-To: <4F43D49E.3010401@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/skbuff.h |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f3cf43d..c11a44e 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -877,6 +877,24 @@ static inline struct sk_buff *skb_peek(const struct sk_buff_head *list_)
 }
 
 /**
+ *	skb_peek_next - peek skb following the given one from a queue
+ *	@skb: skb to start from
+ *	@list_: list to peek at
+ *
+ *	Returns %NULL when the end of the list is met or a pointer to the
+ *	next element. The reference count is not incremented and the
+ *	reference is therefore volatile. Use with caution.
+ */
+static inline struct sk_buff *skb_peek_next(struct sk_buff *skb,
+		const struct sk_buff_head *list_)
+{
+	struct sk_buff *next = skb->next;
+	if (next == (struct sk_buff *)list_)
+		next = NULL;
+	return next;
+}
+
+/**
  *	skb_peek_tail - peek at the tail of an &sk_buff_head
  *	@list_: list to peek at
  *
-- 
1.5.5.6
