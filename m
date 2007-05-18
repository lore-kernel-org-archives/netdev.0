From: Jon Paul Maloy <jon.maloy@ericsson.com>
Subject: [PATCH 2/3] [TIPC]: Use standard socket "not
	implemented" routines
Date: Thu, 17 May 2007 20:33:48 -0400
Message-ID: <11794484293687-git-send-email-jon.maloy@ericsson.com>
References: <1>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Paul Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Sender: tipc-discussion-bounces@lists.sourceforge.net
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This patch modifies TIPC's socket API to utilize existing
generic routines to indicate unsupported operations, rather
than adding similar TIPC-specific routines.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Jon Paul Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c |   55 +++++++++++++---------------------------------------
 1 files changed, 14 insertions(+), 41 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 45832fb..ac7f2aa 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1,8 +1,8 @@
 /*
  * net/tipc/socket.c: TIPC socket API
  *
- * Copyright (c) 2001-2006, Ericsson AB
- * Copyright (c) 2004-2006, Wind River Systems
+ * Copyright (c) 2001-2007, Ericsson AB
+ * Copyright (c) 2004-2007, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -1600,33 +1600,6 @@ static int getsockopt(struct socket *sock,
 }
 
 /**
- * Placeholders for non-implemented functionality
- *
- * Returns error code (POSIX-compliant where defined)
- */
-
-static int ioctl(struct socket *s, u32 cmd, unsigned long arg)
-{
-	return -EINVAL;
-}
-
-static int no_mmap(struct file *file, struct socket *sock,
-		   struct vm_area_struct *vma)
-{
-	return -EINVAL;
-}
-static ssize_t no_sendpage(struct socket *sock, struct page *page,
-			   int offset, size_t size, int flags)
-{
-	return -EINVAL;
-}
-
-static int no_skpair(struct socket *s1, struct socket *s2)
-{
-	return -EOPNOTSUPP;
-}
-
-/**
  * Protocol switches for the various types of TIPC sockets
  */
 
@@ -1636,19 +1609,19 @@ static struct proto_ops msg_ops = {
 	.release	= release,
 	.bind		= bind,
 	.connect	= connect,
-	.socketpair	= no_skpair,
+	.socketpair	= sock_no_socketpair,
 	.accept		= accept,
 	.getname	= get_name,
 	.poll		= poll,
-	.ioctl		= ioctl,
+	.ioctl		= sock_no_ioctl,
 	.listen		= listen,
 	.shutdown	= shutdown,
 	.setsockopt	= setsockopt,
 	.getsockopt	= getsockopt,
 	.sendmsg	= send_msg,
 	.recvmsg	= recv_msg,
-	.mmap		= no_mmap,
-	.sendpage	= no_sendpage
+        .mmap		= sock_no_mmap,
+        .sendpage	= sock_no_sendpage
 };
 
 static struct proto_ops packet_ops = {
@@ -1657,19 +1630,19 @@ static struct proto_ops packet_ops = {
 	.release	= release,
 	.bind		= bind,
 	.connect	= connect,
-	.socketpair	= no_skpair,
+	.socketpair	= sock_no_socketpair,
 	.accept		= accept,
 	.getname	= get_name,
 	.poll		= poll,
-	.ioctl		= ioctl,
+	.ioctl		= sock_no_ioctl,
 	.listen		= listen,
 	.shutdown	= shutdown,
 	.setsockopt	= setsockopt,
 	.getsockopt	= getsockopt,
 	.sendmsg	= send_packet,
 	.recvmsg	= recv_msg,
-	.mmap		= no_mmap,
-	.sendpage	= no_sendpage
+        .mmap		= sock_no_mmap,
+        .sendpage	= sock_no_sendpage
 };
 
 static struct proto_ops stream_ops = {
@@ -1678,19 +1651,19 @@ static struct proto_ops stream_ops = {
 	.release	= release,
 	.bind		= bind,
 	.connect	= connect,
-	.socketpair	= no_skpair,
+	.socketpair	= sock_no_socketpair,
 	.accept		= accept,
 	.getname	= get_name,
 	.poll		= poll,
-	.ioctl		= ioctl,
+	.ioctl		= sock_no_ioctl,
 	.listen		= listen,
 	.shutdown	= shutdown,
 	.setsockopt	= setsockopt,
 	.getsockopt	= getsockopt,
 	.sendmsg	= send_stream,
 	.recvmsg	= recv_stream,
-	.mmap		= no_mmap,
-	.sendpage	= no_sendpage
+        .mmap		= sock_no_mmap,
+        .sendpage	= sock_no_sendpage
 };
 
 static struct net_proto_family tipc_family_ops = {
-- 
1.5.0.5


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
