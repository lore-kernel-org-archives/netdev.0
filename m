From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 02/28] tipc: Eliminate obsolete filter for unexpected unicast messages
Date: Sat, 17 Sep 2011 23:31:58 -0400
Message-ID: <1316316744-29514-3-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49959 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753478Ab1IRDcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:32:42 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Removes a test that ensures unicast link endpoints discard an incoming
message if it will not be consumed by the node itself and cannot be
forwarded to another node, since the preceding test already ensures that
the message is destined for this node and single-cluster TIPC no longer
performs message forwarding.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index f89570c..933764c 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1658,19 +1658,12 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *b_ptr)
 			continue;
 		}
 
+		/* Discard unicast link messages destined for another node */
+
 		if (unlikely(!msg_short(msg) &&
 			     (msg_destnode(msg) != tipc_own_addr)))
 			goto cont;
 
-		/* Discard non-routeable messages destined for another node */
-
-		if (unlikely(!msg_isdata(msg) &&
-			     (msg_destnode(msg) != tipc_own_addr))) {
-			if ((msg_user(msg) != CONN_MANAGER) &&
-			    (msg_user(msg) != MSG_FRAGMENTER))
-				goto cont;
-		}
-
 		/* Locate neighboring node that sent message */
 
 		n_ptr = tipc_node_find(msg_prevnode(msg));
-- 
1.7.4.4
