From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: md5: remove obsolete md5_add() method
Date: Tue, 31 Jan 2012 12:04:42 +0100
Message-ID: <1328007882.2297.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:63772 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753376Ab2AaLEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 06:04:47 -0500
Received: by lagu2 with SMTP id u2so2776360lag.19
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2012 03:04:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We no longer use md5_add() method from struct tcp_sock_af_ops

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/tcp.h   |    4 ----
 net/ipv4/tcp_ipv4.c |    8 --------
 net/ipv6/tcp_ipv6.c |    9 ---------
 3 files changed, 21 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0118ea9..3c90346 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1462,10 +1462,6 @@ struct tcp_sock_af_ops {
 						  const struct sock *sk,
 						  const struct request_sock *req,
 						  const struct sk_buff *skb);
-	int			(*md5_add) (struct sock *sk,
-					    struct sock *addr_sk,
-					    u8 *newkey,
-					    u8 len);
 	int			(*md5_parse) (struct sock *sk,
 					      char __user *optval,
 					      int optlen);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 337ba4c..345e249 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -967,13 +967,6 @@ int tcp_v4_md5_do_add(struct sock *sk, __be32 addr,
 }
 EXPORT_SYMBOL(tcp_v4_md5_do_add);
 
-static int tcp_v4_md5_add_func(struct sock *sk, struct sock *addr_sk,
-			       u8 *newkey, u8 newkeylen)
-{
-	return tcp_v4_md5_do_add(sk, inet_sk(addr_sk)->inet_daddr,
-				 newkey, newkeylen);
-}
-
 int tcp_v4_md5_do_del(struct sock *sk, __be32 addr)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -1853,7 +1846,6 @@ EXPORT_SYMBOL(ipv4_specific);
 static const struct tcp_sock_af_ops tcp_sock_ipv4_specific = {
 	.md5_lookup		= tcp_v4_md5_lookup,
 	.calc_md5_hash		= tcp_v4_md5_hash_skb,
-	.md5_add		= tcp_v4_md5_add_func,
 	.md5_parse		= tcp_v4_parse_md5_keys,
 };
 #endif
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3edd05a..f37769e 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -626,13 +626,6 @@ static int tcp_v6_md5_do_add(struct sock *sk, const struct in6_addr *peer,
 	return 0;
 }
 
-static int tcp_v6_md5_add_func(struct sock *sk, struct sock *addr_sk,
-			       u8 *newkey, __u8 newkeylen)
-{
-	return tcp_v6_md5_do_add(sk, &inet6_sk(addr_sk)->daddr,
-				 newkey, newkeylen);
-}
-
 static int tcp_v6_md5_do_del(struct sock *sk, const struct in6_addr *peer)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -1898,7 +1891,6 @@ static const struct inet_connection_sock_af_ops ipv6_specific = {
 static const struct tcp_sock_af_ops tcp_sock_ipv6_specific = {
 	.md5_lookup	=	tcp_v6_md5_lookup,
 	.calc_md5_hash	=	tcp_v6_md5_hash_skb,
-	.md5_add	=	tcp_v6_md5_add_func,
 	.md5_parse	=	tcp_v6_parse_md5_keys,
 };
 #endif
@@ -1930,7 +1922,6 @@ static const struct inet_connection_sock_af_ops ipv6_mapped = {
 static const struct tcp_sock_af_ops tcp_sock_ipv6_mapped_specific = {
 	.md5_lookup	=	tcp_v4_md5_lookup,
 	.calc_md5_hash	=	tcp_v4_md5_hash_skb,
-	.md5_add	=	tcp_v6_md5_add_func,
 	.md5_parse	=	tcp_v6_parse_md5_keys,
 };
 #endif
