From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 07/16] tipc: Ensure network address change doesn't impact name table updates
Date: Fri, 20 Apr 2012 17:05:15 -0400
Message-ID: <1334955924-907-8-git-send-email-paul.gortmaker@windriver.com>
References: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:65456 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753856Ab2DTVFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 17:05:35 -0400
In-Reply-To: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Revises routines that add and remove an entry from a node's name table
so that the publication scope lists are updated properly even if the
node's network address is changed in mid-operation. The routines now
recognize the default node address of <0.0.0> as an alias for "this node"
even after a new network address has been assigned.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_table.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 1e0518d..25c2975 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -342,12 +342,12 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 	list_add(&publ->zone_list, &info->zone_list);
 	info->zone_list_size++;
 
-	if (in_own_cluster_exact(node)) {
+	if (in_own_cluster(node)) {
 		list_add(&publ->cluster_list, &info->cluster_list);
 		info->cluster_list_size++;
 	}
 
-	if (node == tipc_own_addr) {
+	if (in_own_node(node)) {
 		list_add(&publ->node_list, &info->node_list);
 		info->node_list_size++;
 	}
@@ -411,14 +411,14 @@ found:
 
 	/* Remove publication from cluster scope list, if present */
 
-	if (in_own_cluster_exact(node)) {
+	if (in_own_cluster(node)) {
 		list_del(&publ->cluster_list);
 		info->cluster_list_size--;
 	}
 
 	/* Remove publication from node scope list, if present */
 
-	if (node == tipc_own_addr) {
+	if (in_own_node(node)) {
 		list_del(&publ->node_list);
 		info->node_list_size--;
 	}
-- 
1.7.9.3
