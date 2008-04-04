From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH net-2.6.26] [TIPC]: Remove redundant socket wait queue initialization
Date: Fri,  4 Apr 2008 16:59:46 -0400
Message-ID: <1207342787-12422-2-git-send-email-allan.stephens@windriver.com>
References: <1207342787-12422-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:48284 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751385AbYDDVAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 17:00:34 -0400
In-Reply-To: <1207342787-12422-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch eliminates re-initialization of the standard socket
wait queue used for sleeping in TIPC's socket creation code.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/socket.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 4ad1807..64be71a 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -170,7 +170,6 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol)
 	}
 
 	sock_init_data(sock, sk);
-	init_waitqueue_head(sk->sk_sleep);
 	sk->sk_rcvtimeo = 8 * HZ;   /* default connect timeout = 8s */
 
 	tsock = tipc_sk(sk);
-- 
1.5.3.2

