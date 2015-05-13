From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] tipc: use sock_create_kern interface to create kernel socket
Date: Wed, 13 May 2015 11:20:38 +0800
Message-ID: <1431487238-17050-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <erik.hugne@ericsson.com>,
	<netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40566 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934004AbbEMDUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 23:20:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit eeb1bd5c40ed ("net: Add a struct net parameter to
sock_create_kern"), we should use sock_create_kern() to create kernel
socket as the interface doesn't reference count struct net any more.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/server.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/server.c b/net/tipc/server.c
index a91a2f7..922e04a 100644
--- a/net/tipc/server.c
+++ b/net/tipc/server.c
@@ -325,7 +325,7 @@ static struct socket *tipc_create_listen_sock(struct tipc_conn *con)
 	struct socket *sock = NULL;
 	int ret;
 
-	ret = __sock_create(s->net, AF_TIPC, SOCK_SEQPACKET, 0, &sock, 1);
+	ret = sock_create_kern(s->net, AF_TIPC, SOCK_SEQPACKET, 0, &sock);
 	if (ret < 0)
 		return NULL;
 	ret = kernel_setsockopt(sock, SOL_TIPC, TIPC_IMPORTANCE,
-- 
1.7.9.5
