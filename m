From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 09/10] tipc: Reject payload messages with invalid message type
Date: Mon, 30 Apr 2012 18:37:07 -0400
Message-ID: <1335825428-16053-10-git-send-email-paul.gortmaker@windriver.com>
References: <1335825428-16053-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<jon.maloy@ericsson.com>, <erik.hugne@ericsson.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:45991 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757367Ab2D3WhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 18:37:23 -0400
In-Reply-To: <1335825428-16053-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Adds check to ensure TIPC sockets reject incoming payload messages
that have an unrecognized message type.

Remove the old open question about whether TIPC_ERR_NO_PORT is
the proper return value.  It is appropriate here since there are
valid instances where another node can make use of the reply,
and at this point in time the host is already broadcasting TIPC
data, so there are no real security concerns.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 6d4991e..3c00b40 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1223,11 +1223,8 @@ static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
 
 	/* Reject message if it is wrong sort of message for socket */
 
-	/*
-	 * WOULD IT BE BETTER TO JUST DISCARD THESE MESSAGES INSTEAD?
-	 * "NO PORT" ISN'T REALLY THE RIGHT ERROR CODE, AND THERE MAY
-	 * BE SECURITY IMPLICATIONS INHERENT IN REJECTING INVALID TRAFFIC
-	 */
+	if (msg_type(msg) > TIPC_DIRECT_MSG)
+		return TIPC_ERR_NO_PORT;
 
 	if (sock->state == SS_READY) {
 		if (msg_connected(msg))
-- 
1.7.9.6
