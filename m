From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 5/14] [TIPC] Optimize wakeup logic when socket has no waiting processes
Date: Fri, 13 Oct 2006 13:37:46 +0200
Message-ID: <11607394752213-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:41120 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1751384AbWJMLiA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 07:38:00 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

This patch adds a simple test so TIPC doesn't try waking up processes
waiting on a socket if there are none waiting.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/socket.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index ed900fe..2a6a5a6 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1208,7 +1208,8 @@ static u32 dispatch(struct tipc_port *tp
 	atomic_inc(&tipc_queue_size);
 	skb_queue_tail(&sock->sk->sk_receive_queue, buf);
 
-        wake_up_interruptible(sock->sk->sk_sleep);
+	if (waitqueue_active(sock->sk->sk_sleep))
+		wake_up_interruptible(sock->sk->sk_sleep);
 	return TIPC_OK;
 }
 
@@ -1223,7 +1224,8 @@ static void wakeupdispatch(struct tipc_p
 {
 	struct tipc_sock *tsock = (struct tipc_sock *)tport->usr_handle;
 
-        wake_up_interruptible(tsock->sk.sk_sleep);
+	if (waitqueue_active(tsock->sk.sk_sleep))
+		wake_up_interruptible(tsock->sk.sk_sleep);
 }
 
 /**
-- 
1.4.1

