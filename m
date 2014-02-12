From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 10/14] tipc: rename stack
	variables in function tipc_link_tunnel_rcv
Date: Wed, 12 Feb 2014 13:31:10 -0500
Message-ID: <1392229874-29675-11-git-send-email-jon.maloy@ericsson.com>
References: <1392229874-29675-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1392229874-29675-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

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
index 00f529e..758f7cd 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2176,29 +2176,29 @@ exit:
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


------------------------------------------------------------------------------
Android apps run on BlackBerry 10
Introducing the new BlackBerry 10.2.1 Runtime for Android apps.
Now with support for Jelly Bean, Bluetooth, Mapview and more.
Get your Android app in front of a whole new audience.  Start now.
http://pubads.g.doubleclick.net/gampad/clk?id=124407151&iu=/4140/ostg.clktrk
