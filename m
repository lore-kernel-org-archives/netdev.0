From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] econet: Fix econet_getname() leak
Date: Thu, 06 Aug 2009 15:48:36 +0200
Message-ID: <4A7ADF34.40703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47208 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753187AbZHFNsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 09:48:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

econet_getname() can leak kernel memory to user.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index e114da7..0e0254f 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -520,6 +520,7 @@ static int econet_getname(struct socket *sock, struct sockaddr *uaddr,
 	if (peer)
 		return -EOPNOTSUPP;
 
+	memset(sec, 0, sizeof(*sec));
 	mutex_lock(&econet_mutex);
 
 	sk = sock->sk;
