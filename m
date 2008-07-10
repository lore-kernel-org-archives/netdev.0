From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 2/7 net-next-2.6] tipc: Optimize pointer dereferencing when receiving stream data
Date: Thu, 10 Jul 2008 17:26:06 -0400
Message-ID: <1215725171-10094-3-git-send-email-allan.stephens@windriver.com>
References: <1215725171-10094-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33092 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752964AbYGJVZJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 17:25:09 -0400
In-Reply-To: <1215725171-10094-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch eliminates an unnecessary pointer dereference when
accessing a stream-based socket's receive queue.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/socket.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 9c362c5..ddcb2a7 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1133,7 +1133,7 @@ restart:
 	/* Loop around if more data is required */
 
 	if ((sz_copied < buf_len)    /* didn't get all requested data */
-	    && (!skb_queue_empty(&sock->sk->sk_receive_queue) ||
+	    && (!skb_queue_empty(&sk->sk_receive_queue) ||
 		(flags & MSG_WAITALL))
 				     /* ... and more is ready or required */
 	    && (!(flags & MSG_PEEK)) /* ... and aren't just peeking at data */
-- 
1.5.4.3

