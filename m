From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netrom: Fix nr_getname() leak
Date: Thu, 06 Aug 2009 15:31:07 +0200
Message-ID: <4A7ADB1B.2040401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51434 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbZHFNbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 09:31:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nr_getname() can leak kernel memory to user.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index ce51ce0..ce1a34b 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -847,6 +847,7 @@ static int nr_getname(struct socket *sock, struct sockaddr *uaddr,
 		sax->fsa_ax25.sax25_family = AF_NETROM;
 		sax->fsa_ax25.sax25_ndigis = 1;
 		sax->fsa_ax25.sax25_call   = nr->user_addr;
+		memset(sax->fsa_digipeater, 0, sizeof(sax->fsa_digipeater));
 		sax->fsa_digipeater[0]     = nr->dest_addr;
 		*uaddr_len = sizeof(struct full_sockaddr_ax25);
 	} else {
