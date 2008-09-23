From: David Miller <davem@davemloft.net>
Subject: [PATCH]: tcp: Use skb_queue_is_last() instead of by-hand version.
Date: Tue, 23 Sep 2008 00:36:12 -0700 (PDT)
Message-ID: <20080923.003612.02645173.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35501
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754187AbYIWHgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 03:36:23 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 364F8C8C181
	for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 00:36:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


tcp: Use skb_queue_is_last() instead of by-hand version.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/tcp.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index f857c3e..5c5327e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1284,10 +1284,10 @@ static inline void tcp_unlink_write_queue(struct sk_buff *skb, struct sock *sk)
 	__skb_unlink(skb, &sk->sk_write_queue);
 }
 
-static inline int tcp_skb_is_last(const struct sock *sk,
-				  const struct sk_buff *skb)
+static inline bool tcp_skb_is_last(const struct sock *sk,
+				   const struct sk_buff *skb)
 {
-	return skb->next == (struct sk_buff *)&sk->sk_write_queue;
+	return skb_queue_is_last(&sk->sk_write_queue, skb);
 }
 
 static inline int tcp_write_queue_empty(struct sock *sk)
-- 
1.5.6.5

