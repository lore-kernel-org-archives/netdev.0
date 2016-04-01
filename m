From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 03/11] tcp/dccp: remove BH disable/enable in lookup
Date: Fri,  1 Apr 2016 08:52:14 -0700
Message-ID: <1459525942-30399-4-git-send-email-edumazet@google.com>
References: <1459525942-30399-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Willem de Bruijn <willemb@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35389 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932733AbcDAPwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 11:52:33 -0400
Received: by mail-pa0-f54.google.com with SMTP id td3so93530393pab.2
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 08:52:32 -0700 (PDT)
In-Reply-To: <1459525942-30399-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since linux 2.6.29, lookups only use rcu locking.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_hashtables.h | 7 +------
 net/ipv6/inet6_hashtables.c   | 2 --
 2 files changed, 1 insertion(+), 8 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 50f635c2c536..a77acee93aaf 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -280,11 +280,8 @@ static inline struct sock *inet_lookup_listener(struct net *net,
 	 net_eq(sock_net(__sk), (__net)))
 #endif /* 64-bit arch */
 
-/*
- * Sockets in TCP_CLOSE state are _always_ taken out of the hash, so we need
+/* Sockets in TCP_CLOSE state are _always_ taken out of the hash, so we need
  * not check it for lookups anymore, thanks Alexey. -DaveM
- *
- * Local BH must be disabled here.
  */
 struct sock *__inet_lookup_established(struct net *net,
 				       struct inet_hashinfo *hashinfo,
@@ -326,10 +323,8 @@ static inline struct sock *inet_lookup(struct net *net,
 {
 	struct sock *sk;
 
-	local_bh_disable();
 	sk = __inet_lookup(net, hashinfo, skb, doff, saddr, sport, daddr,
 			   dport, dif);
-	local_bh_enable();
 
 	return sk;
 }
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 70f2628be6fa..d253f32874c9 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -200,10 +200,8 @@ struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
 {
 	struct sock *sk;
 
-	local_bh_disable();
 	sk = __inet6_lookup(net, hashinfo, skb, doff, saddr, sport, daddr,
 			    ntohs(dport), dif);
-	local_bh_enable();
 
 	return sk;
 }
-- 
2.8.0.rc3.226.g39d4020
