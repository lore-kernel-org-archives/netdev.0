From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next] tipc: fix sparse warnings
Date: Wed, 10 Sep 2014 14:02:50 +0200
Message-ID: <1410350570-6145-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:62040 "EHLO
	sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981AbaIJL5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 07:57:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

This fixes the following sparse warnings:
sparse: symbol 'tipc_update_nametbl' was not declared. Should it be static?
Also, the function is changed to return bool upon success, rather than a
potentially freed pointer.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 net/tipc/name_distr.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 780ef71..376d2bb 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -284,8 +284,7 @@ static void named_purge_publ(struct publication *publ)
  * tipc_nametbl_lock must be held.
  * Returns the publication item if successful, otherwise NULL.
  */
-struct publication *tipc_update_nametbl(struct distr_item *i, u32 node,
-					u32 dtype)
+static bool tipc_update_nametbl(struct distr_item *i, u32 node, u32 dtype)
 {
 	struct publication *publ = NULL;
 
@@ -298,6 +297,7 @@ struct publication *tipc_update_nametbl(struct distr_item *i, u32 node,
 			tipc_nodesub_subscribe(&publ->subscr, node, publ,
 					       (net_ev_handler)
 					       named_purge_publ);
+			return true;
 		}
 	} else if (dtype == WITHDRAWAL) {
 		publ = tipc_nametbl_remove_publ(ntohl(i->type), ntohl(i->lower),
@@ -306,11 +306,12 @@ struct publication *tipc_update_nametbl(struct distr_item *i, u32 node,
 		if (publ) {
 			tipc_nodesub_unsubscribe(&publ->subscr);
 			kfree(publ);
+			return true;
 		}
 	} else {
 		pr_warn("Unrecognized name table message received\n");
 	}
-	return publ;
+	return false;
 }
 
 /**
-- 
1.8.3.2
