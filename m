From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v2] sock: make lockdep_sock_is_held inline and conditional on LOCKDEP
Date: Fri,  8 Apr 2016 01:35:18 +0200
Message-ID: <1460072118-10006-1-git-send-email-hannes@stressinduktion.org>
References: <1460066015-22105-1-git-send-email-hannes@stressinduktion.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:51595 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751328AbcDGXf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 19:35:26 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 6FAD2207F2
	for <netdev@vger.kernel.org>; Thu,  7 Apr 2016 19:35:25 -0400 (EDT)
In-Reply-To: <1460066015-22105-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

lockdep_is_held is only specified if CONFIG_LOCKDEP is defined, so make
it depending on it.

Also add the missing inline keyword, so no warnings about unused functions
show up during complilation.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/sock.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index eb2d7c3e120b25..81d6fecec0a2c0 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1360,13 +1360,15 @@ do {									\
 	lockdep_init_map(&(sk)->sk_lock.dep_map, (name), (key), 0);	\
 } while (0)
 
-static bool lockdep_sock_is_held(const struct sock *csk)
+#ifdef CONFIG_LOCKDEP
+static inline bool lockdep_sock_is_held(const struct sock *csk)
 {
 	struct sock *sk = (struct sock *)csk;
 
 	return lockdep_is_held(&sk->sk_lock) ||
 	       lockdep_is_held(&sk->sk_lock.slock);
 }
+#endif
 
 void lock_sock_nested(struct sock *sk, int subclass);
 
-- 
2.5.5
