From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/1] tipc: set 'active' state
	correctly for first established link
Date: Thu, 28 Apr 2016 20:16:08 -0400
Message-ID: <1461888968-26879-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

When we are displaying statistics for the first link established between
two peers, it will always be presented as STANDBY although it in reality
is ACTIVE.

This happens because we forget to set the 'active' flag in the link
instance at the moment it is established. Although this is a bug, it only
has impact on the presentation view of the link, not on its actual
functionality.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/node.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 68d9f7b..c299156 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -554,6 +554,7 @@ static void __tipc_node_link_up(struct tipc_node *n, int bearer_id,
 		*slot1 = bearer_id;
 		tipc_node_fsm_evt(n, SELF_ESTABL_CONTACT_EVT);
 		n->action_flags |= TIPC_NOTIFY_NODE_UP;
+		tipc_link_set_active(nl, true);
 		tipc_bcast_add_peer(n->net, nl, xmitq);
 		return;
 	}
-- 
1.9.1


------------------------------------------------------------------------------
Find and fix application performance issues faster with Applications Manager
Applications Manager provides deep performance insights into multiple tiers of
your business applications. It resolves application problems quickly and
reduces your MTTR. Get your free trial!
https://ad.doubleclick.net/ddm/clk/302982198;130105516;z
