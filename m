From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 06/16] tipc: remove unused
	tipc_link_get_max_pkt routine
Date: Fri, 9 Jan 2015 15:27:03 +0800
Message-ID: <1420788433-17960-7-git-send-email-ying.xue@windriver.com>
References: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Tero.Aho@coriant.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Tested-by: Tero Aho <Tero.Aho@coriant.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c |   27 ---------------------------
 net/tipc/link.h |    1 -
 2 files changed, 28 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index f2531a8..f231058 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2267,33 +2267,6 @@ struct sk_buff *tipc_link_cmd_show_stats(const void *req_tlv_area, int req_tlv_s
 	return buf;
 }
 
-/**
- * tipc_link_get_max_pkt - get maximum packet size to use when sending to destination
- * @dest: network address of destination node
- * @selector: used to select from set of active links
- *
- * If no active link can be found, uses default maximum packet size.
- */
-u32 tipc_link_get_max_pkt(u32 dest, u32 selector)
-{
-	struct tipc_node *n_ptr;
-	struct tipc_link *l_ptr;
-	u32 res = MAX_PKT_DEFAULT;
-
-	if (dest == tipc_own_addr)
-		return MAX_MSG_SIZE;
-
-	n_ptr = tipc_node_find(dest);
-	if (n_ptr) {
-		tipc_node_lock(n_ptr);
-		l_ptr = n_ptr->active_links[selector & 1];
-		if (l_ptr)
-			res = l_ptr->max_pkt;
-		tipc_node_unlock(n_ptr);
-	}
-	return res;
-}
-
 static void link_print(struct tipc_link *l_ptr, const char *str)
 {
 	struct tipc_bearer *b_ptr;
diff --git a/net/tipc/link.h b/net/tipc/link.h
index e96c318..692268d 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -220,7 +220,6 @@ void tipc_link_reset_list(unsigned int bearer_id);
 int tipc_link_xmit_skb(struct sk_buff *skb, u32 dest, u32 selector);
 int tipc_link_xmit(struct sk_buff_head *list, u32 dest, u32 selector);
 int __tipc_link_xmit(struct tipc_link *link, struct sk_buff_head *list);
-u32 tipc_link_get_max_pkt(u32 dest, u32 selector);
 void tipc_link_bundle_rcv(struct sk_buff *buf);
 void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int prob,
 			  u32 gap, u32 tolerance, u32 priority, u32 acked_mtu);
-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
