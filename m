From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 15/20] tipc: remove pointless check for NULL prior to kfree
Date: Fri, 31 Dec 2010 23:59:30 -0500
Message-ID: <1293857975-30267-16-git-send-email-paul.gortmaker@windriver.com>
References: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53335 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994Ab1AAFAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 00:00:12 -0500
In-Reply-To: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

It is acceptable to call kfree() with NULL, so these checks are not
serving any useful purpose.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_distr.c |    4 +---
 net/tipc/port.c       |    4 +---
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 376a30b..a6c989f 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -240,9 +240,7 @@ static void node_is_down(struct publication *publ)
 		    publ->type, publ->lower, publ->node, publ->ref, publ->key);
 	}
 
-	if (p) {
-		kfree(p);
-	}
+	kfree(p);
 }
 
 /**
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 8bacd57..db14b7e 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -269,9 +269,7 @@ int tipc_deleteport(u32 ref)
 		buf = port_build_peer_abort_msg(p_ptr, TIPC_ERR_NO_PORT);
 		tipc_nodesub_unsubscribe(&p_ptr->subscription);
 	}
-	if (p_ptr->user_port) {
-		kfree(p_ptr->user_port);
-	}
+	kfree(p_ptr->user_port);
 
 	spin_lock_bh(&tipc_port_list_lock);
 	list_del(&p_ptr->port_list);
-- 
1.7.3.3

