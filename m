From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next v2 1/3] tipc: remove redundant call to tipc_node_remove_conn
Date: Thu, 19 Mar 2015 09:02:17 +0100
Message-ID: <1426752139-31519-2-git-send-email-erik.hugne@ericsson.com>
References: <1426752139-31519-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <richard.alpe@ericsson.com>, <jon.maloy@ericsson.com>,
	<ying.xue@windriver.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:53164 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313AbbCSIGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 04:06:18 -0400
In-Reply-To: <1426752139-31519-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

tipc_node_remove_conn may be called twice if shutdown() is
called on a socket that have messages in the receive queue.
Calling this function twice does no harm, but is unnecessary
and we remove the redundant call.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 813847d..b6295c0 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2078,7 +2078,6 @@ restart:
 					     TIPC_CONN_SHUTDOWN))
 				tipc_link_xmit_skb(net, skb, dnode,
 						   tsk->portid);
-			tipc_node_remove_conn(net, dnode, tsk->portid);
 		} else {
 			dnode = tsk_peer_node(tsk);
 
-- 
2.1.4
