From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 26/28] tipc: Simplify prohibition of listen and accept for connectionless sockets
Date: Sat, 17 Sep 2011 23:32:22 -0400
Message-ID: <1316316744-29514-27-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50007 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756412Ab1IRDdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:33:02 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

Modifies the proto_ops structure used by TIPC DGRAM and RDM sockets
so that calls to listen() and accept() are handled by existing kernel
"unsupported operation" routines, and eliminates the related checks
in the listen and accept routines used by SEQPACKET and STREAM sockets
that are no longer needed.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 2f90beb..9440a3d 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1483,9 +1483,7 @@ static int listen(struct socket *sock, int len)
 
 	lock_sock(sk);
 
-	if (sock->state == SS_READY)
-		res = -EOPNOTSUPP;
-	else if (sock->state != SS_UNCONNECTED)
+	if (sock->state != SS_UNCONNECTED)
 		res = -EINVAL;
 	else {
 		sock->state = SS_LISTENING;
@@ -1513,10 +1511,6 @@ static int accept(struct socket *sock, struct socket *new_sock, int flags)
 
 	lock_sock(sk);
 
-	if (sock->state == SS_READY) {
-		res = -EOPNOTSUPP;
-		goto exit;
-	}
 	if (sock->state != SS_LISTENING) {
 		res = -EINVAL;
 		goto exit;
@@ -1793,11 +1787,11 @@ static const struct proto_ops msg_ops = {
 	.bind		= bind,
 	.connect	= connect,
 	.socketpair	= sock_no_socketpair,
-	.accept		= accept,
+	.accept		= sock_no_accept,
 	.getname	= get_name,
 	.poll		= poll,
 	.ioctl		= sock_no_ioctl,
-	.listen		= listen,
+	.listen		= sock_no_listen,
 	.shutdown	= shutdown,
 	.setsockopt	= setsockopt,
 	.getsockopt	= getsockopt,
-- 
1.7.4.4
