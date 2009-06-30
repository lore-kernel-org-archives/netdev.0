From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH net-next-2.6] tipc: Add socket options to get number of queued messages
Date: Tue, 30 Jun 2009 09:25:39 -0400
Message-ID: <1246368339-19754-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	"oscar.medina@motorola.com" <oscar.medina@motorola.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33317 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751606AbZF3NZ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jun 2009 09:25:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: oscar.medina@motorola.com <oscar.medina@motorola.com>

This patch allows a TIPC application to determine the number of messages
currently waiting in a socket's receive queue (TIPC_SOCK_RECVQ_DEPTH) or
in all TIPC socket receive queues (TIPC_NODE_RECVQ_DEPTH).

Signed-off-by: Oscar Medina <oscar.medina@motorola.com>
Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 include/linux/tipc.h |    2 ++
 net/tipc/socket.c    |    6 ++++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/include/linux/tipc.h b/include/linux/tipc.h
index bea4694..3d92396 100644
--- a/include/linux/tipc.h
+++ b/include/linux/tipc.h
@@ -209,5 +209,7 @@ struct sockaddr_tipc {
 #define TIPC_SRC_DROPPABLE	128	/* Default: 0 (resend congested msg) */
 #define TIPC_DEST_DROPPABLE	129	/* Default: based on socket type */
 #define TIPC_CONN_TIMEOUT	130	/* Default: 8000 (ms)  */
+#define TIPC_NODE_RECVQ_DEPTH	131	/* Default: none (read only) */
+#define TIPC_SOCK_RECVQ_DEPTH	132	/* Default: none (read only) */
 
 #endif
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 1848693..e8254e8 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1748,6 +1748,12 @@ static int getsockopt(struct socket *sock,
 		value = jiffies_to_msecs(sk->sk_rcvtimeo);
 		/* no need to set "res", since already 0 at this point */
 		break;
+	 case TIPC_NODE_RECVQ_DEPTH:
+		value = (u32)atomic_read(&tipc_queue_size);
+		break;
+	 case TIPC_SOCK_RECVQ_DEPTH:
+		value = skb_queue_len(&sk->sk_receive_queue);
+		break;
 	default:
 		res = -EINVAL;
 	}
-- 
1.5.4.3

