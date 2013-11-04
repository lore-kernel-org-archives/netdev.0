From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/20] netfilter: xt_socket: use sock_gen_put()
Date: Mon,  4 Nov 2013 22:50:26 +0100
Message-ID: <1383601842-4570-5-git-send-email-pablo@netfilter.org>
References: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55669 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753519Ab3KDVuy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Nov 2013 16:50:54 -0500
In-Reply-To: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TCP listener refactoring, part 7 :

Use sock_gen_put() instead of xt_socket_put_sk() for future
SYN_RECV support.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
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
-- 
1.7.10.4
