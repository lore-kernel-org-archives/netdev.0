From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-2.6] can: Fix raw_getname() leak
Date: Fri, 07 Aug 2009 08:27:04 +0200
Message-ID: <4A7BC938.8010504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34758 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752695AbZHGG1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 02:27:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

raw_getname() can leak 10 bytes of kernel memory to user

(two bytes hole between can_family and can_ifindex,
8 bytes at the end of sockaddr_can structure)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/can/raw.c b/net/can/raw.c
index f4cc445..db3152d 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -401,6 +401,7 @@ static int raw_getname(struct socket *sock, struct sockaddr *uaddr,
 	if (peer)
 		return -EOPNOTSUPP;
 
+	memset(addr, 0, sizeof(*addr));
 	addr->can_family  = AF_CAN;
 	addr->can_ifindex = ro->ifindex;
 
