From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/1] tipc: remove remnants of old broadcast code
Date: Wed, 13 Apr 2016 11:45:47 -0400
Message-ID: <1460562347-26436-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	parthasarathy.bhuvaragan@ericsson.com, richard.alpe@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp103.biz.mail.bf1.yahoo.com ([98.139.221.62]:32873 "EHLO
	smtp103.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752575AbcDMPpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 11:45:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We remove a couple of leftover fields in struct tipc_bearer. Those
were used by the old broadcast implementation, and are not needed
any longer. There is no functional changes in this commit.

Acked-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bearer.h | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index e318205..f686e41 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -42,8 +42,6 @@
 #include <net/genetlink.h>
 
 #define MAX_MEDIA	3
-#define MAX_NODES	4096
-#define WSIZE		32
 
 /* Identifiers associated with TIPC message header media address info
  * - address info field is 32 bytes long
@@ -62,16 +60,6 @@
 #define TIPC_MEDIA_TYPE_UDP	3
 
 /**
- * struct tipc_node_map - set of node identifiers
- * @count: # of nodes in set
- * @map: bitmap of node identifiers that are in the set
- */
-struct tipc_node_map {
-	u32 count;
-	u32 map[MAX_NODES / WSIZE];
-};
-
-/**
  * struct tipc_media_addr - destination address used by TIPC bearers
  * @value: address info (format defined by media)
  * @media_id: TIPC media type identifier
@@ -142,7 +130,6 @@ struct tipc_media {
  * @identity: array index of this bearer within TIPC bearer array
  * @link_req: ptr to (optional) structure making periodic link setup requests
  * @net_plane: network plane ('A' through 'H') currently associated with bearer
- * @nodes: indicates which nodes in cluster can be reached through bearer
  *
  * Note: media-specific code is responsible for initialization of the fields
  * indicated below when a bearer is enabled; TIPC's generic bearer code takes
@@ -163,8 +150,6 @@ struct tipc_bearer {
 	u32 identity;
 	struct tipc_link_req *link_req;
 	char net_plane;
-	int node_cnt;
-	struct tipc_node_map nodes;
 };
 
 struct tipc_bearer_names {
-- 
1.9.1
