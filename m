From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [net-next 1/1] tipc: fix rebasing error
Date: Mon, 16 Oct 2017 16:04:51 +0200
Message-ID: <1508162691-31392-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <parthasarathy.bhuvaragan@ericsson.com>, <ying.xue@windriver.com>,
        <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:47596 "EHLO
        sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752290AbdJPOE7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 10:04:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 2f487712b893 ("tipc: guarantee that group broadcast doesn't
bypass group unicast") there was introduced a last-minute rebasing
error that broke non-group communication.

We fix this here.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 723dd69..870b9b8 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1052,6 +1052,7 @@ static bool tipc_data_input(struct tipc_link *l, struct sk_buff *skb,
 			return true;
 		}
 	case CONN_MANAGER:
+		skb_queue_tail(inputq, skb);
 		return true;
 	case GROUP_PROTOCOL:
 		skb_queue_tail(mc_inputq, skb);
-- 
2.1.4
