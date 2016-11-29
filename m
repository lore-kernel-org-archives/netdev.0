From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH v2 net 5/5] l2tp: fix address test in __l2tp_ip6_bind_lookup()
Date: Tue, 29 Nov 2016 13:09:48 +0100
Message-ID: <017236a1113ff42aab77d6ce62c0a571e67d36c6.1480419658.git.g.nault@alphalink.fr>
References: <cover.1480419658.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
        Chris Elston <celston@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:42376 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756654AbcK2MKC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 07:10:02 -0500
Content-Disposition: inline
In-Reply-To: <cover.1480419658.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The '!(addr && ipv6_addr_equal(addr, laddr))' part of the conditional
matches if addr is NULL or if addr != laddr.
But the intend of __l2tp_ip6_bind_lookup() is to find a sockets with
the same address, so the ipv6_addr_equal() condition needs to be
inverted.

For better clarity and consistency with the rest of the expression, the
(!X || X == Y) notation is used instead of !(X && X != Y).

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_ip6.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 4a86440..aa821cb 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -72,7 +72,7 @@ static struct sock *__l2tp_ip6_bind_lookup(struct net *net,
 
 		if ((l2tp->conn_id == tunnel_id) &&
 		    net_eq(sock_net(sk), net) &&
-		    !(addr && ipv6_addr_equal(addr, laddr)) &&
+		    (!addr || ipv6_addr_equal(addr, laddr)) &&
 		    (!sk->sk_bound_dev_if || !dif ||
 		     sk->sk_bound_dev_if == dif))
 			goto found;
-- 
2.10.2
