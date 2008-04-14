From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 6/7 net-2.6.26] [TIPC]: Cosmetic changes to TIPC connect() code
Date: Mon, 14 Apr 2008 17:16:33 -0400
Message-ID: <1208207794-2229-7-git-send-email-allan.stephens@windriver.com>
References: <1208207794-2229-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:55795 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762626AbYDNVS1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 17:18:27 -0400
In-Reply-To: <1208207794-2229-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes TIPC's connect routine to conform to Linux
kernel style norms of indentation, line length, etc.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/socket.c |  143 +++++++++++++++++++++++++++--------------------------
 1 files changed, 72 insertions(+), 71 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 348e4ff..df19603 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1248,77 +1248,78 @@ static void wakeupdispatch(struct tipc_port *tport)
 static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 		   int flags)
 {
-   struct tipc_sock *tsock = tipc_sk(sock->sk);
-   struct sockaddr_tipc *dst = (struct sockaddr_tipc *)dest;
-   struct msghdr m = {NULL,};
-   struct sk_buff *buf;
-   struct tipc_msg *msg;
-   int res;
-
-   /* For now, TIPC does not allow use of connect() with DGRAM or RDM types */
-
-   if (sock->state == SS_READY)
-	   return -EOPNOTSUPP;
-
-   /* For now, TIPC does not support the non-blocking form of connect() */
-
-   if (flags & O_NONBLOCK)
-	   return -EWOULDBLOCK;
-
-   /* Issue Posix-compliant error code if socket is in the wrong state */
-
-   if (sock->state == SS_LISTENING)
-	   return -EOPNOTSUPP;
-   if (sock->state == SS_CONNECTING)
-	   return -EALREADY;
-   if (sock->state != SS_UNCONNECTED)
-	   return -EISCONN;
-
-   /*
-    * Reject connection attempt using multicast address
-    *
-    * Note: send_msg() validates the rest of the address fields,
-    *       so there's no need to do it here
-    */
-
-   if (dst->addrtype == TIPC_ADDR_MCAST)
-	   return -EINVAL;
-
-   /* Send a 'SYN-' to destination */
-
-   m.msg_name = dest;
-   m.msg_namelen = destlen;
-   if ((res = send_msg(NULL, sock, &m, 0)) < 0) {
-	   sock->state = SS_DISCONNECTING;
-	   return res;
-   }
-
-   if (mutex_lock_interruptible(&tsock->lock))
-	   return -ERESTARTSYS;
-
-   /* Wait for destination's 'ACK' response */
-
-   res = wait_event_interruptible_timeout(*sock->sk->sk_sleep,
-					  skb_queue_len(&sock->sk->sk_receive_queue),
-					  sock->sk->sk_rcvtimeo);
-   buf = skb_peek(&sock->sk->sk_receive_queue);
-   if (res > 0) {
-	   msg = buf_msg(buf);
-	   res = auto_connect(sock, tsock, msg);
-	   if (!res) {
-		   if (!msg_data_sz(msg))
-			   advance_queue(tsock);
-	   }
-   } else {
-	   if (res == 0) {
-		   res = -ETIMEDOUT;
-	   } else
-		   { /* leave "res" unchanged */ }
-	   sock->state = SS_DISCONNECTING;
-   }
-
-   mutex_unlock(&tsock->lock);
-   return res;
+	struct tipc_sock *tsock = tipc_sk(sock->sk);
+	struct sockaddr_tipc *dst = (struct sockaddr_tipc *)dest;
+	struct msghdr m = {NULL,};
+	struct sk_buff *buf;
+	struct tipc_msg *msg;
+	int res;
+
+	/* For now, TIPC does not allow use of connect() with DGRAM/RDM types */
+
+	if (sock->state == SS_READY)
+		return -EOPNOTSUPP;
+
+	/* For now, TIPC does not support the non-blocking form of connect() */
+
+	if (flags & O_NONBLOCK)
+		return -EWOULDBLOCK;
+
+	/* Issue Posix-compliant error code if socket is in the wrong state */
+
+	if (sock->state == SS_LISTENING)
+		return -EOPNOTSUPP;
+	if (sock->state == SS_CONNECTING)
+		return -EALREADY;
+	if (sock->state != SS_UNCONNECTED)
+		return -EISCONN;
+
+	/*
+	 * Reject connection attempt using multicast address
+	 *
+	 * Note: send_msg() validates the rest of the address fields,
+	 *       so there's no need to do it here
+	 */
+
+	if (dst->addrtype == TIPC_ADDR_MCAST)
+		return -EINVAL;
+
+	/* Send a 'SYN-' to destination */
+
+	m.msg_name = dest;
+	m.msg_namelen = destlen;
+	res = send_msg(NULL, sock, &m, 0);
+	if (res < 0) {
+		sock->state = SS_DISCONNECTING;
+		return res;
+	}
+
+	if (mutex_lock_interruptible(&tsock->lock))
+		return -ERESTARTSYS;
+
+	/* Wait for destination's 'ACK' response */
+
+	res = wait_event_interruptible_timeout(*sock->sk->sk_sleep,
+			skb_queue_len(&sock->sk->sk_receive_queue),
+			sock->sk->sk_rcvtimeo);
+	buf = skb_peek(&sock->sk->sk_receive_queue);
+	if (res > 0) {
+		msg = buf_msg(buf);
+		res = auto_connect(sock, tsock, msg);
+		if (!res) {
+			if (!msg_data_sz(msg))
+				advance_queue(tsock);
+		}
+	} else {
+		if (res == 0)
+			res = -ETIMEDOUT;
+		else
+			; /* leave "res" unchanged */
+		sock->state = SS_DISCONNECTING;
+	}
+
+	mutex_unlock(&tsock->lock);
+	return res;
 }
 
 /**
-- 
1.5.3.2

