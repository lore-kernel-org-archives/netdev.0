From: ZHAO Gang <gamerh2o@gmail.com>
Subject: [PATCH RESENT net-next] net: remove function sk_reset_txq()
Date: Tue, 22 Oct 2013 16:23:38 +0800
Message-ID: <20131022082338.GA19349@will>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:60984 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753655Ab3JVIYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 04:24:00 -0400
Received: by mail-pd0-f175.google.com with SMTP id g10so7876313pdj.6
        for <netdev@vger.kernel.org>; Tue, 22 Oct 2013 01:24:00 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What sk_reset_txq() does is just calls function sk_tx_queue_reset(),
and sk_reset_txq() is used only in sock.h, by dst_negative_advice().
Let dst_negative_advice() calls sk_tx_queue_reset() directly so we
can remove unneeded sk_reset_txq().

Signed-off-by: ZHAO Gang <gamerh2o@gmail.com>
---
Hope this time I don't mess it up. Sorry for the inconvenience.
---
 include/net/sock.h | 4 +---
 net/core/sock.c    | 6 ------
 2 files changed, 1 insertion(+), 9 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 86bb066..c93542f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1746,8 +1746,6 @@ sk_dst_get(struct sock *sk)
 	return dst;
 }
 
-void sk_reset_txq(struct sock *sk);
-
 static inline void dst_negative_advice(struct sock *sk)
 {
 	struct dst_entry *ndst, *dst = __sk_dst_get(sk);
@@ -1757,7 +1755,7 @@ static inline void dst_negative_advice(struct sock *sk)
 
 		if (ndst != dst) {
 			rcu_assign_pointer(sk->sk_dst_cache, ndst);
-			sk_reset_txq(sk);
+			sk_tx_queue_clear(sk);
 		}
 	}
 }
diff --git a/net/core/sock.c b/net/core/sock.c
index 440afdc..ab20ed9 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -475,12 +475,6 @@ discard_and_relse:
 }
 EXPORT_SYMBOL(sk_receive_skb);
 
-void sk_reset_txq(struct sock *sk)
-{
-	sk_tx_queue_clear(sk);
-}
-EXPORT_SYMBOL(sk_reset_txq);
-
 struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie)
 {
 	struct dst_entry *dst = __sk_dst_get(sk);
-- 
1.8.3.1
