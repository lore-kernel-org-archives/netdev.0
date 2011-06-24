From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 13/20] tipc: Eliminate unused field in bearer structure
Date: Fri, 24 Jun 2011 18:07:20 -0400
Message-ID: <1308953247-25266-14-git-send-email-paul.gortmaker@windriver.com>
References: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34396 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757451Ab1FXWHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 18:07:50 -0400
In-Reply-To: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Gets rid of counter that records the number of times a bearer has
resumed after congestion or blocking, since the value is never
referenced anywhere.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c |    1 -
 net/tipc/bearer.h |    2 --
 2 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 85209ea..85eba9c 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -402,7 +402,6 @@ void tipc_bearer_lock_push(struct tipc_bearer *b_ptr)
 void tipc_continue(struct tipc_bearer *b_ptr)
 {
 	spin_lock_bh(&b_ptr->lock);
-	b_ptr->continue_count++;
 	if (!list_empty(&b_ptr->cong_links))
 		tipc_k_signal((Handler)tipc_bearer_lock_push, (unsigned long)b_ptr);
 	b_ptr->blocked = 0;
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 31d6172..5ad70ef 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -107,7 +107,6 @@ struct media {
  * @link_req: ptr to (optional) structure making periodic link setup requests
  * @links: list of non-congested links associated with bearer
  * @cong_links: list of congested links associated with bearer
- * @continue_count: # of times bearer has resumed after congestion or blocking
  * @active: non-zero if bearer structure is represents a bearer
  * @net_plane: network plane ('A' through 'H') currently associated with bearer
  * @nodes: indicates which nodes in cluster can be reached through bearer
@@ -129,7 +128,6 @@ struct tipc_bearer {
 	struct link_req *link_req;
 	struct list_head links;
 	struct list_head cong_links;
-	u32 continue_count;
 	int active;
 	char net_plane;
 	struct tipc_node_map nodes;
-- 
1.7.4.4

