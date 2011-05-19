From: David Miller <davem@davemloft.net>
Subject: [PATCH] rxrpc: Kill set but unused variable 'sp' in
 rxrpc_rotate_tx_window()
Date: Thu, 19 May 2011 18:34:56 -0400 (EDT)
Message-ID: <20110519.183456.1255882469582117931.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34518 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754538Ab1ESWe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 18:34:57 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4JMYuoD028273
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 15:34:57 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/rxrpc/ar-ack.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index b6ffe4e..f99cfce 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -375,7 +375,6 @@ protocol_error:
  */
 static void rxrpc_rotate_tx_window(struct rxrpc_call *call, u32 hard)
 {
-	struct rxrpc_skb_priv *sp;
 	unsigned long _skb;
 	int tail = call->acks_tail, old_tail;
 	int win = CIRC_CNT(call->acks_head, tail, call->acks_winsz);
@@ -387,7 +386,6 @@ static void rxrpc_rotate_tx_window(struct rxrpc_call *call, u32 hard)
 	while (call->acks_hard < hard) {
 		smp_read_barrier_depends();
 		_skb = call->acks_window[tail] & ~1;
-		sp = rxrpc_skb((struct sk_buff *) _skb);
 		rxrpc_free_skb((struct sk_buff *) _skb);
 		old_tail = tail;
 		tail = (tail + 1) & (call->acks_winsz - 1);
-- 
1.7.4.4

