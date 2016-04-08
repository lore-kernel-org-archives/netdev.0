From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] sock: make lockdep_sock_is_held inline and
 conditional on LOCKDEP
Date: Thu, 07 Apr 2016 20:40:54 -0400 (EDT)
Message-ID: <20160407.204054.1721184100791312803.davem@davemloft.net>
References: <1460066015-22105-1-git-send-email-hannes@stressinduktion.org>
	<1460072118-10006-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57205 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244AbcDHAk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 20:40:57 -0400
In-Reply-To: <1460072118-10006-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri,  8 Apr 2016 01:35:18 +0200

> lockdep_is_held is only specified if CONFIG_LOCKDEP is defined, so make
> it depending on it.
> 
> Also add the missing inline keyword, so no warnings about unused functions
> show up during complilation.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

I already applied your inline patch, I applied the following:

====================
[PATCH] net: Fix build failure due to lockdep_sock_is_held().

Needs to be protected with CONFIG_LOCKDEP.

Based upon a patch by Hannes Frederic Sowa.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/sock.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index 46b2937..81d6fec 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1360,6 +1360,7 @@ do {									\
 	lockdep_init_map(&(sk)->sk_lock.dep_map, (name), (key), 0);	\
 } while (0)
 
+#ifdef CONFIG_LOCKDEP
 static inline bool lockdep_sock_is_held(const struct sock *csk)
 {
 	struct sock *sk = (struct sock *)csk;
@@ -1367,6 +1368,7 @@ static inline bool lockdep_sock_is_held(const struct sock *csk)
 	return lockdep_is_held(&sk->sk_lock) ||
 	       lockdep_is_held(&sk->sk_lock.slock);
 }
+#endif
 
 void lock_sock_nested(struct sock *sk, int subclass);
 
-- 
2.1.0
