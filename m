From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 15/16] tipc: Ensure network address change doesn't impact rejected message
Date: Fri, 20 Apr 2012 17:05:23 -0400
Message-ID: <1334955924-907-16-git-send-email-paul.gortmaker@windriver.com>
References: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:65478 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754597Ab2DTVFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 17:05:45 -0400
In-Reply-To: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Revises handling of a rejected message to ensure that a locally
originated message is returned properly even if the node's network
address is changed in mid-operation. The routine now treats the
default node address of <0.0.0> as an alias for "this node" when
determining where to send a returned message.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index c50819b..0f40b10 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -444,7 +444,7 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 	/* send returned message & dispose of rejected message */
 
 	src_node = msg_prevnode(msg);
-	if (src_node == tipc_own_addr)
+	if (in_own_node(src_node))
 		tipc_port_recv_msg(rbuf);
 	else
 		tipc_link_send(rbuf, src_node, msg_link_selector(rmsg));
-- 
1.7.9.3
