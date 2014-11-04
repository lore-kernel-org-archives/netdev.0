From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] ipv6: move INET6_MATCH() to include/net/inet6_hashtables.h
Date: Tue,  4 Nov 2014 10:59:47 -0800
Message-ID: <1415127587-29030-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:39610 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084AbaKDS76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 13:59:58 -0500
Received: by mail-pd0-f175.google.com with SMTP id y13so14199063pdi.20
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 10:59:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is only used in net/ipv6/inet6_hashtables.c.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/linux/ipv6.h           | 10 ----------
 include/net/inet6_hashtables.h | 10 ++++++++++
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 7121a2e..c694e7b 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -317,14 +317,4 @@ static inline struct raw6_sock *raw6_sk(const struct sock *sk)
 #define tcp_twsk_ipv6only(__sk)		0
 #define inet_v6_ipv6only(__sk)		0
 #endif /* IS_ENABLED(CONFIG_IPV6) */
-
-#define INET6_MATCH(__sk, __net, __saddr, __daddr, __ports, __dif)	\
-	(((__sk)->sk_portpair == (__ports))			&&	\
-	 ((__sk)->sk_family == AF_INET6)			&&	\
-	 ipv6_addr_equal(&(__sk)->sk_v6_daddr, (__saddr))		&&	\
-	 ipv6_addr_equal(&(__sk)->sk_v6_rcv_saddr, (__daddr))	&&	\
-	 (!(__sk)->sk_bound_dev_if	||				\
-	   ((__sk)->sk_bound_dev_if == (__dif))) 		&&	\
-	 net_eq(sock_net(__sk), (__net)))
-
 #endif /* _IPV6_H */
diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index d1d2728..9201afe0 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -99,4 +99,14 @@ struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
 			  const struct in6_addr *daddr, const __be16 dport,
 			  const int dif);
 #endif /* IS_ENABLED(CONFIG_IPV6) */
+
+#define INET6_MATCH(__sk, __net, __saddr, __daddr, __ports, __dif)	\
+	(((__sk)->sk_portpair == (__ports))			&&	\
+	 ((__sk)->sk_family == AF_INET6)			&&	\
+	 ipv6_addr_equal(&(__sk)->sk_v6_daddr, (__saddr))		&&	\
+	 ipv6_addr_equal(&(__sk)->sk_v6_rcv_saddr, (__daddr))	&&	\
+	 (!(__sk)->sk_bound_dev_if	||				\
+	   ((__sk)->sk_bound_dev_if == (__dif))) 		&&	\
+	 net_eq(sock_net(__sk), (__net)))
+
 #endif /* _INET6_HASHTABLES_H */
-- 
1.8.3.1
