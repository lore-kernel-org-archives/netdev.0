From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] appletalk: fix atalk_getname() leak
Date: Thu, 06 Aug 2009 14:27:43 +0200
Message-ID: <4A7ACC3F.9070600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35331 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753302AbZHFM1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 08:27:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

atalk_getname() can leak 8 bytes of kernel memory to user

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 590b839..9ef6ff2 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1237,6 +1237,7 @@ static int atalk_getname(struct socket *sock, struct sockaddr *uaddr,
 			return -ENOBUFS;
 
 	*uaddr_len = sizeof(struct sockaddr_at);
+	memset(&sat.sat_zero, 0, sizeof(sat.sat_zero));
 
 	if (peer) {
 		if (sk->sk_state != TCP_ESTABLISHED)
