From: David Miller <davem@davemloft.net>
Subject: [PATCH] rxrpc: Kill set but unused variable 'sp' in
 rxrpc_process_connection()
Date: Thu, 19 May 2011 18:36:19 -0400 (EDT)
Message-ID: <20110519.183619.49610615090907051.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34531 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754538Ab1ESWgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 18:36:21 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4JMaKP6028467
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 15:36:21 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/rxrpc/ar-connevent.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/rxrpc/ar-connevent.c b/net/rxrpc/ar-connevent.c
index 0505cdc..e7ed43a 100644
--- a/net/rxrpc/ar-connevent.c
+++ b/net/rxrpc/ar-connevent.c
@@ -259,7 +259,6 @@ void rxrpc_process_connection(struct work_struct *work)
 {
 	struct rxrpc_connection *conn =
 		container_of(work, struct rxrpc_connection, processor);
-	struct rxrpc_skb_priv *sp;
 	struct sk_buff *skb;
 	u32 abort_code = RX_PROTOCOL_ERROR;
 	int ret;
@@ -276,8 +275,6 @@ void rxrpc_process_connection(struct work_struct *work)
 	/* go through the conn-level event packets, releasing the ref on this
 	 * connection that each one has when we've finished with it */
 	while ((skb = skb_dequeue(&conn->rx_queue))) {
-		sp = rxrpc_skb(skb);
-
 		ret = rxrpc_process_event(conn, skb, &abort_code);
 		switch (ret) {
 		case -EPROTO:
-- 
1.7.4.4

