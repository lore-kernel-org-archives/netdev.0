From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] sock: use hlist_entry_safe
Date: Fri, 20 Jan 2017 22:27:04 +0800
Message-ID: <697f2692562e48afa03304a7e605e8adbee8437e.1484829069.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use hlist_entry_safe() instead of open-coding it.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 include/net/sock.h | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 4077ec4..c4e1caf1 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -544,8 +544,7 @@ static inline struct sock *sk_nulls_head(const struct hlist_nulls_head *head)
 
 static inline struct sock *sk_next(const struct sock *sk)
 {
-	return sk->sk_node.next ?
-		hlist_entry(sk->sk_node.next, struct sock, sk_node) : NULL;
+	return hlist_entry_safe(sk->sk_node.next, struct sock, sk_node);
 }
 
 static inline struct sock *sk_nulls_next(const struct sock *sk)
-- 
2.9.3
