From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next v2 10/14] tipc: rename stack variables in function tipc_link_tunnel_rcv
Date: Thu, 13 Feb 2014 17:29:14 -0500
Message-ID: <1392330558-19048-11-git-send-email-jon.maloy@ericsson.com>
References: <1392330558-19048-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp103.biz.mail.ne1.yahoo.com ([98.138.207.10]:21088 "HELO
	smtp103.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752557AbaBMW3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:29:44 -0500
In-Reply-To: <1392330558-19048-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the previous redesign of the tunnel reception algorithm and
functions, we finalize it by renaming a couple of stack variables
in tipc_tunnel_rcv(). This makes it more consistent with the naming
scheme elsewhere in this part of the code.

This change is purely cosmetic, with no functional changes.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c |   22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 3136788..b678c2e 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2177,29 +2177,29 @@ exit:
 static int tipc_link_tunnel_rcv(struct tipc_node *n_ptr,
 				struct sk_buff **buf)
 {
-	struct sk_buff *tunnel_buf = *buf;
-	struct tipc_link *dest_link;
-	struct tipc_msg *tunnel_msg = buf_msg(tunnel_buf);
-	u32 bearer_id = msg_bearer_id(tunnel_msg);
+	struct sk_buff *t_buf = *buf;
+	struct tipc_link *l_ptr;
+	struct tipc_msg *t_msg = buf_msg(t_buf);
+	u32 bearer_id = msg_bearer_id(t_msg);
 
 	*buf = NULL;
 
 	if (bearer_id >= MAX_BEARERS)
 		goto exit;
 
-	dest_link = n_ptr->links[bearer_id];
-	if (!dest_link)
+	l_ptr = n_ptr->links[bearer_id];
+	if (!l_ptr)
 		goto exit;
 
-	if (msg_type(tunnel_msg) == DUPLICATE_MSG)
-		tipc_link_dup_rcv(dest_link, tunnel_buf);
-	else if (msg_type(tunnel_msg) == ORIGINAL_MSG)
-		*buf = tipc_link_failover_rcv(dest_link, tunnel_buf);
+	if (msg_type(t_msg) == DUPLICATE_MSG)
+		tipc_link_dup_rcv(l_ptr, t_buf);
+	else if (msg_type(t_msg) == ORIGINAL_MSG)
+		*buf = tipc_link_failover_rcv(l_ptr, t_buf);
 	else
 		pr_warn("%sunknown tunnel pkt received\n", link_co_err);
 
 exit:
-	kfree_skb(tunnel_buf);
+	kfree_skb(t_buf);
 	return *buf != NULL;
 }
 
-- 
1.7.9.5
