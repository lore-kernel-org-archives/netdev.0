From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: remove obsolete helpers
Date: Wed, 11 Oct 2017 20:45:40 -0700
Message-ID: <1507779940.31614.43.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:44761 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753086AbdJLDpm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 23:45:42 -0400
Received: by mail-pf0-f195.google.com with SMTP id x7so3144909pfa.1
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 20:45:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Remove three inline helpers that are no longer needed.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h |   17 -----------------
 1 file changed, 17 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 15163454174babdcb465904f725b919268dd1bc7..3b3b9b968e2d4b3469aa4f69d708a440bda578e7 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1629,18 +1629,6 @@ static inline struct sk_buff *tcp_write_queue_tail(const struct sock *sk)
 	return skb_peek_tail(&sk->sk_write_queue);
 }
 
-static inline struct sk_buff *tcp_write_queue_next(const struct sock *sk,
-						   const struct sk_buff *skb)
-{
-	return skb_queue_next(&sk->sk_write_queue, skb);
-}
-
-static inline struct sk_buff *tcp_write_queue_prev(const struct sock *sk,
-						   const struct sk_buff *skb)
-{
-	return skb_queue_prev(&sk->sk_write_queue, skb);
-}
-
 #define tcp_for_write_queue_from_safe(skb, tmp, sk)			\
 	skb_queue_walk_from_safe(&(sk)->sk_write_queue, skb, tmp)
 
@@ -1697,11 +1685,6 @@ static inline void tcp_add_write_queue_tail(struct sock *sk, struct sk_buff *skb
 	}
 }
 
-static inline void __tcp_add_write_queue_head(struct sock *sk, struct sk_buff *skb)
-{
-	__skb_queue_head(&sk->sk_write_queue, skb);
-}
-
 /* Insert new before skb on the write queue of sk.  */
 static inline void tcp_insert_write_queue_before(struct sk_buff *new,
 						  struct sk_buff *skb,
