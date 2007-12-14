From: akpm@linux-foundation.org
Subject: [patch 3/4] tipc: fix semaphore handling
Date: Thu, 13 Dec 2007 16:02:36 -0800
Message-ID: <200712140002.lBE02b3G025494@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	allan.stephens@windriver.com, jon.maloy@ericsson.com,
	kjwinchester@gmail.com, per.liden@ericsson.com, stable@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54450 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764413AbXLNAC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 19:02:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

As noted by Kevin, tipc's release() does down_interruptible() and ignores the
return value.  So if signal_pending() we'll end up doing up() on a non-downed
semaphore.  Fix.

Cc: Kevin Winchester <kjwinchester@gmail.com>
Cc: Per Liden <per.liden@ericsson.com>
Cc: Jon Maloy <jon.maloy@ericsson.com>
Cc: Allan Stephens <allan.stephens@windriver.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: <stable@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/tipc/socket.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN net/tipc/socket.c~tipc-fix-semaphore-handling net/tipc/socket.c
--- a/net/tipc/socket.c~tipc-fix-semaphore-handling
+++ a/net/tipc/socket.c
@@ -253,7 +253,7 @@ static int release(struct socket *sock)
 	dbg("sock_delete: %x\n",tsock);
 	if (!tsock)
 		return 0;
-	down_interruptible(&tsock->sem);
+	down(&tsock->sem);
 	if (!sock->sk) {
 		up(&tsock->sem);
 		return 0;
_
