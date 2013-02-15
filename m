From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 3/3] tipc: remove redundant checking for the number of iovecs in a send request
Date: Fri, 15 Feb 2013 17:57:47 -0500
Message-ID: <1360969067-29956-4-git-send-email-paul.gortmaker@windriver.com>
References: <1360969067-29956-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:38738 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752886Ab3BOW6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 17:58:09 -0500
In-Reply-To: <1360969067-29956-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

As the number of iovecs in a send request is already limited within
UIO_MAXIOV(i.e. 1024) in __sys_sendmsg(), it's unnecessary to check it
again in TIPC stack.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index cbe2f6e..a9622b6 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -503,8 +503,7 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 	if (unlikely((m->msg_namelen < sizeof(*dest)) ||
 		     (dest->family != AF_TIPC)))
 		return -EINVAL;
-	if ((total_len > TIPC_MAX_USER_MSG_SIZE) ||
-	    (m->msg_iovlen > (unsigned int)INT_MAX))
+	if (total_len > TIPC_MAX_USER_MSG_SIZE)
 		return -EMSGSIZE;
 
 	if (iocb)
@@ -612,8 +611,7 @@ static int send_packet(struct kiocb *iocb, struct socket *sock,
 	if (unlikely(dest))
 		return send_msg(iocb, sock, m, total_len);
 
-	if ((total_len > TIPC_MAX_USER_MSG_SIZE) ||
-	    (m->msg_iovlen > (unsigned int)INT_MAX))
+	if (total_len > TIPC_MAX_USER_MSG_SIZE)
 		return -EMSGSIZE;
 
 	if (iocb)
@@ -698,8 +696,7 @@ static int send_stream(struct kiocb *iocb, struct socket *sock,
 		goto exit;
 	}
 
-	if ((total_len > (unsigned int)INT_MAX) ||
-	    (m->msg_iovlen > (unsigned int)INT_MAX)) {
+	if (total_len > (unsigned int)INT_MAX) {
 		res = -EMSGSIZE;
 		goto exit;
 	}
-- 
1.8.1.2
