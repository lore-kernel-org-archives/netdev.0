From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 1/7 net-2.6.26] [TIPC]: Skip connection flow control in connectionless sockets
Date: Mon, 14 Apr 2008 17:16:28 -0400
Message-ID: <1208207794-2229-2-git-send-email-allan.stephens@windriver.com>
References: <1208207794-2229-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:55745 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752508AbYDNVSX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 17:18:23 -0400
In-Reply-To: <1208207794-2229-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch optimizes the receive path for SOCK_DGRAM and SOCK_RDM
messages by skipping over code that handles connection-based flow
control.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/socket.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index ca6f52f..91aa2dc 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -919,7 +919,8 @@ restart:
 	/* Consume received message (optional) */
 
 	if (likely(!(flags & MSG_PEEK))) {
-		if (unlikely(++tsock->p->conn_unacked >= TIPC_FLOW_CONTROL_WIN))
+		if ((sock->state != SS_READY) &&
+		    (++tsock->p->conn_unacked >= TIPC_FLOW_CONTROL_WIN))
 			tipc_acknowledge(tsock->p->ref, tsock->p->conn_unacked);
 		advance_queue(tsock);
 	}
-- 
1.5.3.2

