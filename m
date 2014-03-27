From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 01/10] tipc: remove unnecessary
	checking for node object
Date: Thu, 27 Mar 2014 12:54:30 +0800
Message-ID: <1395896080-7926-2-git-send-email-ying.xue@windriver.com>
References: <1395896080-7926-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1395896080-7926-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

tipc_node_create routine doesn't need to check whether a node
object specified with a node address exists or not because its
caller(ie, tipc_disc_recv_msg routine) has checked this before
calling it.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/node.c |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 0b0f6c7..7c9b667 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -95,12 +95,6 @@ struct tipc_node *tipc_node_create(u32 addr)
 
 	spin_lock_bh(&node_create_lock);
 
-	n_ptr = tipc_node_find(addr);
-	if (n_ptr) {
-		spin_unlock_bh(&node_create_lock);
-		return n_ptr;
-	}
-
 	n_ptr = kzalloc(sizeof(*n_ptr), GFP_ATOMIC);
 	if (!n_ptr) {
 		spin_unlock_bh(&node_create_lock);
-- 
1.7.9.5


------------------------------------------------------------------------------
