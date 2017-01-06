From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next 3/4] l2tp: remove useless NULL check in
 __l2tp_ip*_bind_lookup()
Date: Fri, 6 Jan 2017 20:03:56 +0100
Message-ID: <998651e453306521ca1d006be7457cfb15b3e4bf.1483727525.git.g.nault@alphalink.fr>
References: <cover.1483727525.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
        Chris Elston <celston@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:60925 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032833AbdAFTEA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 14:04:00 -0500
Content-Disposition: inline
In-Reply-To: <cover.1483727525.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If "l2tp" was NULL, that'd mean "sk" is NULL too. This can't happen
since "sk" is returned by sk_for_each_bound().

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_ip.c  | 3 ---
 net/l2tp/l2tp_ip6.c | 3 ---
 2 files changed, 6 deletions(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index e5686bf898f7..499d3cdbfbc8 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -56,9 +56,6 @@ static struct sock *__l2tp_ip_bind_lookup(const struct net *net, __be32 laddr,
 		const struct l2tp_ip_sock *l2tp = l2tp_ip_sk(sk);
 		const struct inet_sock *inet = inet_sk(sk);
 
-		if (l2tp == NULL)
-			continue;
-
 		if ((l2tp->conn_id == tunnel_id) &&
 		    net_eq(sock_net(sk), net) &&
 		    !(inet->inet_rcv_saddr && inet->inet_rcv_saddr != laddr) &&
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 2f6be6ddc8cb..7165b06d7b25 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -69,9 +69,6 @@ static struct sock *__l2tp_ip6_bind_lookup(const struct net *net,
 		const struct in6_addr *sk_raddr = &sk->sk_v6_daddr;
 		const struct l2tp_ip6_sock *l2tp = l2tp_ip6_sk(sk);
 
-		if (l2tp == NULL)
-			continue;
-
 		if ((l2tp->conn_id == tunnel_id) &&
 		    net_eq(sock_net(sk), net) &&
 		    (!sk_laddr || ipv6_addr_any(sk_laddr) || ipv6_addr_equal(sk_laddr, laddr)) &&
-- 
2.11.0
