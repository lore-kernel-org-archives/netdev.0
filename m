From: akpm@osdl.org
Subject: [patch 1/3] net/ipv6: bh_lock_sock_nested on tcp_v6_rcv
Date: Mon, 25 Sep 2006 16:43:07 -0700
Message-ID: <200609252343.k8PNh7DH002845@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, fleite@redhat.com,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:30901 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751748AbWIYXn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 19:43:28 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabio Olive Leite <fleite@redhat.com>

A while ago Ingo patched tcp_v4_rcv on net/ipv4/tcp_ipv4.c to use
bh_lock_sock_nested and silence a lock validator warning. This fixed
it for IPv4, but recently I saw a report of the same warning on IPv6.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 net/ipv6/tcp_ipv6.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN net/ipv6/tcp_ipv6.c~net-ipv6-bh_lock_sock_nested-on-tcp_v6_rcv net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c~net-ipv6-bh_lock_sock_nested-on-tcp_v6_rcv
+++ a/net/ipv6/tcp_ipv6.c
@@ -1237,7 +1237,7 @@ process:
 
 	skb->dev = NULL;
 
-	bh_lock_sock(sk);
+	bh_lock_sock_nested(sk);
 	ret = 0;
 	if (!sock_owned_by_user(sk)) {
 #ifdef CONFIG_NET_DMA
_
