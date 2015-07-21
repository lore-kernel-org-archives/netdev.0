From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/1] tipc: fix compatibility bug
Date: Tue, 21 Jul 2015 06:42:28 -0400
Message-ID: <1437475348-2163-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.bf1.yahoo.com ([98.139.221.63]:41142 "EHLO
	smtp104.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754043AbbGUKnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 06:43:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit d999297c3dbbe7fdd832f7fa4ec84301e170b3e6
("tipc: reduce locking scope during packet reception") we introduced
a new function tipc_link_proto_rcv(). This function contains a bug,
so that it sometimes by error sends out a non-zero link priority value
in created protocol messages.

The bug may lead to an extra link reset at initial link establising
with older nodes. This will never happen more than once, whereafter
the link will work as intended.

We fix this bug in this commit.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 55b675d..b63d573 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1639,7 +1639,7 @@ static int tipc_link_proto_rcv(struct tipc_link *l, struct sk_buff *skb,
 			rcvgap = peers_snd_nxt - l->rcv_nxt;
 		if (rcvgap || (msg_probe(hdr)))
 			tipc_link_build_proto_msg(l, STATE_MSG, 0, rcvgap,
-						  0, l->mtu, xmitq);
+						  0, 0, xmitq);
 		tipc_link_release_pkts(l, msg_ack(hdr));
 
 		/* If NACK, retransmit will now start at right position */
-- 
1.9.1
