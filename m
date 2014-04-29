From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] tipc: fix memory leak of publications
Date: Tue, 29 Apr 2014 11:12:18 +0800
Message-ID: <1398741138-30523-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Paul.Gortmaker@windriver.com>,
	<erik.hugne@ericsson.com>, <huzhijiang@gmail.com>,
	<netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:40351 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751567AbaD2DMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 23:12:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 1bb8dce57f4d15233688c68990852a10eb1cd79f ("tipc: fix memory
leak during module removal") introduced a memory leak issue: when
name table is stopped, it's forgotten that publication instances are
freed properly. Additionally the useless "continue" statement in
tipc_nametbl_stop() is removed as well.

Reported-by: Jason <huzhijiang@gmail.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/name_table.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 9bcf4b5..9d7d37d 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -969,6 +969,7 @@ static void tipc_purge_publications(struct name_seq *seq)
 	list_for_each_entry_safe(publ, safe, &info->zone_list, zone_list) {
 		tipc_nametbl_remove_publ(publ->type, publ->lower, publ->node,
 					 publ->ref, publ->key);
+		kfree(publ);
 	}
 }
 
@@ -990,7 +991,6 @@ void tipc_nametbl_stop(void)
 		hlist_for_each_entry_safe(seq, safe, seq_head, ns_list) {
 			tipc_purge_publications(seq);
 		}
-		continue;
 	}
 	kfree(table.types);
 	table.types = NULL;
-- 
1.7.9.5
