From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] rose: Fix rose_getname() leak
Date: Thu, 06 Aug 2009 15:34:06 +0200
Message-ID: <4A7ADBCE.2040501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50353 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755430AbZHFNeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 09:34:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rose_getname() can leak kernel memory to user.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index f0a76f6..e5f478c 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -954,6 +954,7 @@ static int rose_getname(struct socket *sock, struct sockaddr *uaddr,
 	struct rose_sock *rose = rose_sk(sk);
 	int n;
 
+	memset(srose, 0, sizeof(*srose));
 	if (peer != 0) {
 		if (sk->sk_state != TCP_ESTABLISHED)
 			return -ENOTCONN;
