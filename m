From: "Stephens, Allan" <allan.stephens@windriver.com>
Subject: [PATCH 02/08] [TIPC]: Add argument validation for shutdown()
Date: Fri, 22 Feb 2008 11:59:06 -0800
Message-ID: <AF1602CB2550CE4381C0C75118A7856B0246C88F@ala-mail02.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:37358 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932094AbYBVT71 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 14:59:27 -0500
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.wrs.com (8.13.6/8.13.6) with ESMTP id m1MJxOna017774
	for <netdev@vger.kernel.org>; Fri, 22 Feb 2008 11:59:25 -0800 (PST)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch validates that the "how" argument to shutdown()
is SHUT_RDWR, since this is the only form that TIPC supports.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/socket.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 2290903..e5a6983 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1419,20 +1419,25 @@ exit:
 /**
  * shutdown - shutdown socket connection
  * @sock: socket structure
- * @how: direction to close (unused; always treated as read + write)
+ * @how: direction to close (must be SHUT_RDWR)
  *
  * Terminates connection (if necessary), then purges socket's receive
queue.
  *
  * Returns 0 on success, errno otherwise
  */
 
+#ifndef SHUT_RDWR
+#define SHUT_RDWR 2
+#endif
+
 static int shutdown(struct socket *sock, int how)
 {
 	struct tipc_sock* tsock = tipc_sk(sock->sk);
 	struct sk_buff *buf;
 	int res;
 
-	/* Could return -EINVAL for an invalid "how", but why bother? */
+	if (how != SHUT_RDWR)
+		return -EINVAL;
 
 	if (down_interruptible(&tsock->sem))
 		return -ERESTARTSYS;
-- 
1.5.3.2
