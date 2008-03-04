From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 2/7 net-2.6.26] [TIPC]: Add argument validation for shutdown()
Date: Tue,  4 Mar 2008 16:20:14 -0500
Message-ID: <1204665619-6345-3-git-send-email-allan.stephens@windriver.com>
References: <1204665619-6345-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:48056 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758625AbYCDVgI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2008 16:36:08 -0500
In-Reply-To: <1204665619-6345-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch validates that the "how" argument to shutdown()
is SHUT_RDWR, since this is the only form that TIPC supports.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/socket.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 2290903..8677da7 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1419,7 +1419,7 @@ exit:
 /**
  * shutdown - shutdown socket connection
  * @sock: socket structure
- * @how: direction to close (unused; always treated as read + write)
+ * @how: direction to close (must be SHUT_RDWR)
  *
  * Terminates connection (if necessary), then purges socket's receive queue.
  *
@@ -1432,7 +1432,8 @@ static int shutdown(struct socket *sock, int how)
 	struct sk_buff *buf;
 	int res;
 
-	/* Could return -EINVAL for an invalid "how", but why bother? */
+	if (how != SHUT_RDWR)
+		return -EINVAL;
 
 	if (down_interruptible(&tsock->sem))
 		return -ERESTARTSYS;
-- 
1.5.3.2

