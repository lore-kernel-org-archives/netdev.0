From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] l2tp: small cleanup
Date: Thu, 21 Oct 2010 13:36:11 +0200
Message-ID: <1287660971.6871.97.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60227 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757702Ab0JULgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 07:36:16 -0400
Received: by wwf26 with SMTP id 26so2444710wwf.1
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 04:36:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/l2tp/l2tp_ip.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 226a0ae..1c770c0 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -65,9 +65,7 @@ static struct sock *__l2tp_ip_bind_lookup(struct net *net, __be32 laddr, int dif
 			continue;
 
 		if ((l2tp->conn_id == tunnel_id) &&
-#ifdef CONFIG_NET_NS
-		    (sk->sk_net == net) &&
-#endif
+		    net_eq(sock_net(sk), net) &&
 		    !(inet->inet_rcv_saddr && inet->inet_rcv_saddr != laddr) &&
 		    !(sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif))
 			goto found;


