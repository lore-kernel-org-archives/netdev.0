From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [net 1/1] tipc: correct initialization of skb list
Date: Sat, 7 Oct 2017 14:32:49 +0200
Message-ID: <1507379569-26507-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <parthasarathy.bhuvaragan@ericsson.com>, <ying.xue@windriver.com>,
        <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:58937 "EHLO
        sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751027AbdJGMc7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 08:32:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We change the initialization of the skb transmit buffer queues
in the functions tipc_bcast_xmit() and tipc_rcast_xmit() to also
initialize their spinlocks. This is needed because we may, during
error conditions, need to call skb_queue_purge() on those queues
further down the stack.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 7d99029..a140dd4 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -233,7 +233,7 @@ static int tipc_bcast_xmit(struct net *net, struct sk_buff_head *pkts,
 	struct sk_buff_head xmitq;
 	int rc = 0;
 
-	__skb_queue_head_init(&xmitq);
+	skb_queue_head_init(&xmitq);
 	tipc_bcast_lock(net);
 	if (tipc_link_bc_peers(l))
 		rc = tipc_link_xmit(l, pkts, &xmitq);
@@ -263,7 +263,7 @@ static int tipc_rcast_xmit(struct net *net, struct sk_buff_head *pkts,
 	u32 dst, selector;
 
 	selector = msg_link_selector(buf_msg(skb_peek(pkts)));
-	__skb_queue_head_init(&_pkts);
+	skb_queue_head_init(&_pkts);
 
 	list_for_each_entry_safe(n, tmp, &dests->list, list) {
 		dst = n->value;
-- 
2.1.4
