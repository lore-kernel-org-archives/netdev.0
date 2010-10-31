From: Vasiliy Kulikov <segooon@gmail.com>
Subject: [PATCH 3/3] net: tipc: fix information leak to userland
Date: Sun, 31 Oct 2010 20:10:32 +0300
Message-ID: <1288545032-16481-1-git-send-email-segooon@gmail.com>
Cc: Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:58185 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756257Ab0JaRKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Oct 2010 13:10:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Structure sockaddr_tipc is copied to userland with padding bytes after
"id" field in union field "name" unitialized.  It leads to leaking of
contents of kernel stack memory.  We have to initialize them to zero.

Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>
---
 net/tipc/socket.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 33217fc..e9f0d50 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -396,6 +396,7 @@ static int get_name(struct socket *sock, struct sockaddr *uaddr,
 	struct sockaddr_tipc *addr = (struct sockaddr_tipc *)uaddr;
 	struct tipc_sock *tsock = tipc_sk(sock->sk);
 
+	memset(addr, 0, sizeof(*addr));
 	if (peer) {
 		if ((sock->state != SS_CONNECTED) &&
 			((peer != 2) || (sock->state != SS_DISCONNECTING)))
-- 
1.7.0.4

