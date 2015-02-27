From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next v2 1/5] tipc: only create header
	copy for name distr messages
Date: Fri, 27 Feb 2015 08:56:54 +0100
Message-ID: <1425023818-12880-2-git-send-email-erik.hugne@ericsson.com>
References: <1425023818-12880-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1425023818-12880-1-git-send-email-erik.hugne@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Erik Hugne <erik.hugne@ericsson.com>

The TIPC name distributor pushes topology updates to the cluster
neighbors. Currently this is done in a unicast manner, and the
skb holding the update is cloned for each cluster member. This
is unnecessary, as we only modify the destnode field in the header
so we change it to do pskb_copy instead.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/name_distr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index fcb0791..506aaa5 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -98,7 +98,7 @@ void named_cluster_distribute(struct net *net, struct sk_buff *skb)
 			continue;
 		if (!tipc_node_active_links(node))
 			continue;
-		oskb = skb_copy(skb, GFP_ATOMIC);
+		oskb = pskb_copy(skb, GFP_ATOMIC);
 		if (!oskb)
 			break;
 		msg_set_destnode(buf_msg(oskb), dnode);
-- 
2.1.4


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
