From: ZHAO Gang <gamerh2o@gmail.com>
Subject: [PATCH] net: remove function sk_reset_txq()
Date: Sun, 20 Oct 2013 09:14:47 +0800
Message-ID: <20131020011447.GA22399@will>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

What sk_reset_txq() does is just calls function sk_tx_queue_reset(),
and sk_reset_txq() is used only in sock.c, by dst_negative_advice().
Let dst_negative_advice() calls sk_tx_queue_reset() directly so we
can remove unneeded sk_reset_txq().

Signed-off-by: ZHAO Gang <gamerh2o@gmail.com>
---
 include/net/sock.h | 4 +---
 net/core/sock.c    | 6 ------
 2 files changed, 1 insertion(+), 9 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 1d37a80..db66682 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1752,8 +1752,6 @@ sk_dst_get(struct sock *sk)
 	return dst;
 }
 
-extern void sk_reset_txq(struct sock *sk);
-
 static inline void dst_negative_advice(struct sock *sk)
 {
 	struct dst_entry *ndst, *dst = __sk_dst_get(sk);
@@ -1763,7 +1761,7 @@ static inline void dst_negative_advice(struct sock *sk)
 
 		if (ndst != dst) {
 			rcu_assign_pointer(sk->sk_dst_cache, ndst);
-			sk_reset_txq(sk);
+			sk_tx_queue_clear(sk);
 		}
 	}
 }
diff --git a/net/core/sock.c b/net/core/sock.c
index 5b6beba..3f1545f 100644
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
