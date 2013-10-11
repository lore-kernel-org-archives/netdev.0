From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] netfilter: xt_socket: use sock_gen_put()
Date: Fri, 11 Oct 2013 09:03:25 -0700
Message-ID: <1381507405.4971.108.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:64990 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754457Ab3JKQD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 12:03:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TCP listener refactoring, part 7 :

Use sock_gen_put() instead of xt_socket_put_sk() for future
SYN_RECV support.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_socket.c |   13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 3dd0e37..1ba6793 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -35,15 +35,6 @@
 #include <net/netfilter/nf_conntrack.h>
 #endif
 
-static void
-xt_socket_put_sk(struct sock *sk)
-{
-	if (sk->sk_state == TCP_TIME_WAIT)
-		inet_twsk_put(inet_twsk(sk));
-	else
-		sock_put(sk);
-}
-
 static int
 extract_icmp4_fields(const struct sk_buff *skb,
 		    u8 *protocol,
@@ -216,7 +207,7 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 					inet_twsk(sk)->tw_transparent));
 
 		if (sk != skb->sk)
-			xt_socket_put_sk(sk);
+			sock_gen_put(sk);
 
 		if (wildcard || !transparent)
 			sk = NULL;
@@ -381,7 +372,7 @@ socket_mt6_v1_v2(const struct sk_buff *skb, struct xt_action_param *par)
 					inet_twsk(sk)->tw_transparent));
 
 		if (sk != skb->sk)
-			xt_socket_put_sk(sk);
+			sock_gen_put(sk);
 
 		if (wildcard || !transparent)
 			sk = NULL;
