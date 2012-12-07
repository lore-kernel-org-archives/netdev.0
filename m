From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 08/10] tipc: eliminate connection setup for implied connect in recv_msg()
Date: Fri, 7 Dec 2012 09:28:16 -0500
Message-ID: <1354890498-6448-9-git-send-email-paul.gortmaker@windriver.com>
References: <1354890498-6448-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:62577 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030741Ab2LGO2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 09:28:39 -0500
In-Reply-To: <1354890498-6448-1-git-send-email-paul.gortmaker@windriver.com>
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
index 1ba3b6f..0df42fa 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -954,13 +954,6 @@ restart:
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
