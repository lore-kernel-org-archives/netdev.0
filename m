From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] irda: Fix irda_getname() leak
Date: Thu, 06 Aug 2009 15:55:04 +0200
Message-ID: <4A7AE0B8.8010600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52790 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755267AbZHFNzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 09:55:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

irda_getname() can leak kernel memory to user.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index cb762c8..3ec2b43 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -714,6 +714,7 @@ static int irda_getname(struct socket *sock, struct sockaddr *uaddr,
 	struct sock *sk = sock->sk;
 	struct irda_sock *self = irda_sk(sk);
 
+	memset(&saddr, 0, sizeof(saddr));
 	if (peer) {
 		if (sk->sk_state != TCP_ESTABLISHED)
 			return -ENOTCONN;
