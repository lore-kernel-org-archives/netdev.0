From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 11/17] tipc: Minor optimization to broadcast link synchronization logic
Date: Wed, 29 Feb 2012 18:18:37 -0500
Message-ID: <1330557523-2024-12-git-send-email-paul.gortmaker@windriver.com>
References: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53973 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965328Ab2B2XTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 18:19:05 -0500
In-Reply-To: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Optimizes processing done when contact with a neighboring node is
established to avoid recording the current state of outgoing broadcast
messages if the neighboring node isn't a valid broadcast link destination,
since this state information isn't needed for such nodes.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/node.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index d7f8b7b..12ddc65 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -270,10 +270,8 @@ static void node_established_contact(struct tipc_node *n_ptr)
 {
 	tipc_k_signal((Handler)tipc_named_node_up, n_ptr->addr);
 
-	/* Syncronize broadcast acks */
-	n_ptr->bclink.acked = tipc_bclink_get_last_sent();
-
 	if (n_ptr->bclink.supportable) {
+		n_ptr->bclink.acked = tipc_bclink_get_last_sent();
 		tipc_bclink_add_node(n_ptr->addr);
 		n_ptr->bclink.supported = 1;
 	}
-- 
1.7.9.1
