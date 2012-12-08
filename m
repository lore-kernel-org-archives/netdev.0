From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 7/9] tipc: eliminate connection setup for implied connect in recv_msg()
Date: Fri, 7 Dec 2012 20:19:16 -0500
Message-ID: <1354929558-16948-8-git-send-email-paul.gortmaker@windriver.com>
References: <1354929558-16948-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:46485 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757479Ab2LHBTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 20:19:37 -0500
In-Reply-To: <1354929558-16948-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

As connection setup is now completed asynchronously in BH context,
in the function filter_connect(), the corresponding code in recv_msg()
becomes redundant.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index dbce274..ef75b62 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -946,13 +946,6 @@ restart:
 	sz = msg_data_sz(msg);
 	err = msg_errcode(msg);
 
-	/* Complete connection setup for an implied connect */
-	if (unlikely(sock->state == SS_CONNECTING)) {
-		res = auto_connect(sock, msg);
-		if (res)
-			goto exit;
-	}
-
 	/* Discard an empty non-errored message & try again */
 	if ((!sz) && (!err)) {
 		advance_rx_queue(sk);
-- 
1.7.12.1
