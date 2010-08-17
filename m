From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 12/14] tipc: Minor enhancements to name table display format
Date: Tue, 17 Aug 2010 17:00:14 -0400
Message-ID: <1282078816-11844-13-git-send-email-paul.gortmaker@windriver.com>
References: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57147 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109Ab0HQVA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 17:00:28 -0400
In-Reply-To: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Eliminate printing of dashes after name table column headers
(to adhere more closely to the standard format used in tipc-config),
and simplify name table display logic using array lookups rather
than if-then-else logic.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_table.c |   44 ++++++++++++++++----------------------------
 1 files changed, 16 insertions(+), 28 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 8ba7962..d504e49 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -877,7 +877,7 @@ static void subseq_list(struct sub_seq *sseq, struct print_buf *buf, u32 depth,
 			u32 index)
 {
 	char portIdStr[27];
-	char *scopeStr;
+	const char *scope_str[] = {"", " zone", " cluster", " node"};
 	struct publication *publ = sseq->zone_list;
 
 	tipc_printf(buf, "%-10u %-10u ", sseq->lower, sseq->upper);
@@ -893,15 +893,8 @@ static void subseq_list(struct sub_seq *sseq, struct print_buf *buf, u32 depth,
 			 tipc_node(publ->node), publ->ref);
 		tipc_printf(buf, "%-26s ", portIdStr);
 		if (depth > 3) {
-			if (publ->node != tipc_own_addr)
-				scopeStr = "";
-			else if (publ->scope == TIPC_NODE_SCOPE)
-				scopeStr = "node";
-			else if (publ->scope == TIPC_CLUSTER_SCOPE)
-				scopeStr = "cluster";
-			else
-				scopeStr = "zone";
-			tipc_printf(buf, "%-10u %s", publ->key, scopeStr);
+			tipc_printf(buf, "%-10u %s", publ->key,
+				    scope_str[publ->scope]);
 		}
 
 		publ = publ->zone_list_next;
@@ -951,24 +944,19 @@ static void nameseq_list(struct name_seq *seq, struct print_buf *buf, u32 depth,
 
 static void nametbl_header(struct print_buf *buf, u32 depth)
 {
-	tipc_printf(buf, "Type       ");
-
-	if (depth > 1)
-		tipc_printf(buf, "Lower      Upper      ");
-	if (depth > 2)
-		tipc_printf(buf, "Port Identity              ");
-	if (depth > 3)
-		tipc_printf(buf, "Publication");
-
-	tipc_printf(buf, "\n-----------");
-
-	if (depth > 1)
-		tipc_printf(buf, "--------------------- ");
-	if (depth > 2)
-		tipc_printf(buf, "-------------------------- ");
-	if (depth > 3)
-		tipc_printf(buf, "------------------");
-
+	const char *header[] = {
+		"Type       ",
+		"Lower      Upper      ",
+		"Port Identity              ",
+		"Publication Scope"
+	};
+
+	int i;
+
+	if (depth > 4)
+		depth = 4;
+	for (i = 0; i < depth; i++)
+		tipc_printf(buf, header[i]);
 	tipc_printf(buf, "\n");
 }
 
-- 
1.7.2.1

