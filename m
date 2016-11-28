From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 5/5] l2tp: fix address test in __l2tp_ip6_bind_lookup()
Date: Mon, 28 Nov 2016 20:40:02 +0100
Message-ID: <49e8d347d29c46d773db8dcf1b653894abc6490a.1480360512.git.g.nault@alphalink.fr>
References: <cover.1480360512.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
        Chris Elston <celston@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:48878 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754504AbcK1TkF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 14:40:05 -0500
Content-Disposition: inline
In-Reply-To: <cover.1480360512.git.g.nault@alphalink.fr>
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
