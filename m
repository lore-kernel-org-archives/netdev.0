From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 16/23] tipc: Eliminate useless check when network address is assigned
Date: Tue, 27 Dec 2011 12:39:35 -0500
Message-ID: <1325007582-31610-17-git-send-email-paul.gortmaker@windriver.com>
References: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39473 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754816Ab1L0RkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 12:40:07 -0500
In-Reply-To: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Gets rid of an unnecessary check in the routine that updates the port id
of a node's name publications when the node is assigned a network address,
since the routine is only invoked if the new address is different from
the existing one.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_distr.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index b7ca1bd..be8306f 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -322,10 +322,9 @@ void tipc_named_recv(struct sk_buff *buf)
 /**
  * tipc_named_reinit - re-initialize local publication list
  *
- * This routine is called whenever TIPC networking is (re)enabled.
+ * This routine is called whenever TIPC networking is enabled.
  * All existing publications by this node that have "cluster" or "zone" scope
- * are updated to reflect the node's current network address.
- * (If the node's address is unchanged, the update loop terminates immediately.)
+ * are updated to reflect the node's new network address.
  */
 
 void tipc_named_reinit(void)
@@ -333,10 +332,9 @@ void tipc_named_reinit(void)
 	struct publication *publ;
 
 	write_lock_bh(&tipc_nametbl_lock);
-	list_for_each_entry(publ, &publ_root, local_list) {
-		if (publ->node == tipc_own_addr)
-			break;
+
+	list_for_each_entry(publ, &publ_root, local_list)
 		publ->node = tipc_own_addr;
-	}
+
 	write_unlock_bh(&tipc_nametbl_lock);
 }
-- 
1.7.4.4
