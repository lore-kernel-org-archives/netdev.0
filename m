From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next 2/4] l2tp: make __l2tp_ip*_bind_lookup() parameters
 'const'
Date: Fri, 6 Jan 2017 20:03:55 +0100
Message-ID: <8b63170f416f2dc9599878c5a130eddec180ac13.1483727525.git.g.nault@alphalink.fr>
References: <cover.1483727525.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
        Chris Elston <celston@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:60917 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032823AbdAFTD6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 14:03:58 -0500
Content-Disposition: inline
In-Reply-To: <cover.1483727525.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add const qualifier wherever possible for __l2tp_ip_bind_lookup() and
__l2tp_ip6_bind_lookup().

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_ip.c  | 4 ++--
 net/l2tp/l2tp_ip6.c | 6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 992761e721af..e5686bf898f7 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -53,8 +53,8 @@ static struct sock *__l2tp_ip_bind_lookup(const struct net *net, __be32 laddr,
 	struct sock *sk;
 
 	sk_for_each_bound(sk, &l2tp_ip_bind_table) {
-		struct inet_sock *inet = inet_sk(sk);
-		struct l2tp_ip_sock *l2tp = l2tp_ip_sk(sk);
+		const struct l2tp_ip_sock *l2tp = l2tp_ip_sk(sk);
+		const struct inet_sock *inet = inet_sk(sk);
 
 		if (l2tp == NULL)
 			continue;
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 331ccf5a7bad..2f6be6ddc8cb 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -57,8 +57,8 @@ static inline struct l2tp_ip6_sock *l2tp_ip6_sk(const struct sock *sk)
 	return (struct l2tp_ip6_sock *)sk;
 }
 
-static struct sock *__l2tp_ip6_bind_lookup(struct net *net,
-					   struct in6_addr *laddr,
+static struct sock *__l2tp_ip6_bind_lookup(const struct net *net,
+					   const struct in6_addr *laddr,
 					   const struct in6_addr *raddr,
 					   int dif, u32 tunnel_id)
 {
@@ -67,7 +67,7 @@ static struct sock *__l2tp_ip6_bind_lookup(struct net *net,
 	sk_for_each_bound(sk, &l2tp_ip6_bind_table) {
 		const struct in6_addr *sk_laddr = inet6_rcv_saddr(sk);
 		const struct in6_addr *sk_raddr = &sk->sk_v6_daddr;
-		struct l2tp_ip6_sock *l2tp = l2tp_ip6_sk(sk);
+		const struct l2tp_ip6_sock *l2tp = l2tp_ip6_sk(sk);
 
 		if (l2tp == NULL)
 			continue;
-- 
2.11.0
