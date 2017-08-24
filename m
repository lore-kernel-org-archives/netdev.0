From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net v1 3/3] tipc: context imbalance at node read unlock
Date: Thu, 24 Aug 2017 16:31:24 +0200
Message-ID: <1503585084-14079-4-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1503585084-14079-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
        <jon.maloy@ericsson.com>, <maloy@donjonn.com>,
        <ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:52624 "EHLO
        sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753115AbdHXOdD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 10:33:03 -0400
In-Reply-To: <1503585084-14079-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we fail to find a valid bearer in tipc_node_get_linkname(),
node_read_unlock() is called without holding the node read lock.

This commit fixes this error.

Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/node.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index b113a52f8914..7dd22330a6b4 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -1126,8 +1126,8 @@ int tipc_node_get_linkname(struct net *net, u32 bearer_id, u32 addr,
 		strncpy(linkname, tipc_link_name(link), len);
 		err = 0;
 	}
-exit:
 	tipc_node_read_unlock(node);
+exit:
 	tipc_node_put(node);
 	return err;
 }
-- 
2.1.4
