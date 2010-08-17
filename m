From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 10/14] tipc: Optimize tipc_node_has_active_links()
Date: Tue, 17 Aug 2010 17:00:12 -0400
Message-ID: <1282078816-11844-11-git-send-email-paul.gortmaker@windriver.com>
References: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57138 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292Ab0HQVA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 17:00:27 -0400
In-Reply-To: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Eliminate unnecessary checking for null node pointer and redundant
check of second active link array entry.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/node.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index b634942..9408517 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -237,8 +237,7 @@ void tipc_node_link_down(struct tipc_node *n_ptr, struct link *l_ptr)
 
 int tipc_node_has_active_links(struct tipc_node *n_ptr)
 {
-	return (n_ptr &&
-		((n_ptr->active_links[0]) || (n_ptr->active_links[1])));
+	return n_ptr->active_links[0] != NULL;
 }
 
 int tipc_node_has_redundant_links(struct tipc_node *n_ptr)
-- 
1.7.2.1

