From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] tipc: link: Remove unused function
Date: Tue, 13 Jan 2015 19:24:58 +0100
Message-ID: <1421173498-4012-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the function tipc_link_get_max_pkt() that is not used anywhere.

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 net/tipc/link.c |   27 ---------------------------
 net/tipc/link.h |    1 -
 2 files changed, 28 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 1db162a..a18f5ce 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2327,33 +2327,6 @@ struct sk_buff *tipc_link_cmd_show_stats(const void *req_tlv_area, int req_tlv_s
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
index b567a34..9b91eb6 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -228,7 +228,6 @@ void tipc_link_reset(struct tipc_link *l_ptr);
 void tipc_link_reset_list(unsigned int bearer_id);
 int tipc_link_xmit(struct sk_buff *buf, u32 dest, u32 selector);
 int __tipc_link_xmit(struct tipc_link *link, struct sk_buff *buf);
-u32 tipc_link_get_max_pkt(u32 dest, u32 selector);
 void tipc_link_bundle_rcv(struct sk_buff *buf);
 void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int prob,
 			  u32 gap, u32 tolerance, u32 priority, u32 acked_mtu);
-- 
1.7.10.4
