From: Gerlando Falauto <gerlando.falauto@keymile.com>
Subject: [PATCH v3 1/3] tipc: cosmetic: clean up comments
Date: Tue, 30 Apr 2013 09:33:17 +0200
Message-ID: <1367307199-10577-1-git-send-email-gerlando.falauto@keymile.com>
References: <1367244820-29881-1-git-send-email-gerlando.falauto@keymile.com>
Cc: jon.maloy@ericsson.com, erik.hugne@ericsson.com,
	ying.xue@windriver.com, holger.brunck@keymile.com,
	Gerlando Falauto <gerlando.falauto@keymile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:56440 "EHLO
	mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758756Ab3D3HjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 03:39:04 -0400
In-Reply-To: <1367244820-29881-1-git-send-email-gerlando.falauto@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Gerlando Falauto <gerlando.falauto@keymile.com>
---
Changes from v2:
* Split cosmetic from functional changes

 net/tipc/bcast.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 2655c9f..8438e01 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -584,8 +584,7 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 {
 	int bp_index;
 
-	/*
-	 * Prepare broadcast link message for reliable transmission,
+	/* Prepare broadcast link message for reliable transmission,
 	 * if first time trying to send it;
 	 * preparation is skipped for broadcast link protocol messages
 	 * since they are sent in an unreliable manner and don't need it
@@ -613,11 +612,12 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 		struct tipc_bearer *s = bcbearer->bpairs[bp_index].secondary;
 
 		if (!p)
-			break;	/* no more bearers to try */
+			break; /* No more bearers to try */
 
-		tipc_nmap_diff(&bcbearer->remains, &p->nodes, &bcbearer->remains_new);
+		tipc_nmap_diff(&bcbearer->remains, &p->nodes,
+			       &bcbearer->remains_new);
 		if (bcbearer->remains_new.count == bcbearer->remains.count)
-			continue;	/* bearer pair doesn't add anything */
+			continue; /* Nothing added by bearer pair */
 
 		if (!tipc_bearer_blocked(p))
 			tipc_bearer_send(p, buf, &p->media->bcast_addr);
@@ -628,13 +628,14 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 			/* unable to send on either bearer */
 			continue;
 
+		/* Swap bearers for next packet */
 		if (s) {
 			bcbearer->bpairs[bp_index].primary = s;
 			bcbearer->bpairs[bp_index].secondary = p;
 		}
 
 		if (bcbearer->remains_new.count == 0)
-			break;	/* all targets reached */
+			break; /* All targets reached */
 
 		bcbearer->remains = bcbearer->remains_new;
 	}
-- 
1.7.10.1
