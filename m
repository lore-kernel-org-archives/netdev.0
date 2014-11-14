From: Holger Brunck <holger.brunck@keymile.com>
Subject: [PATCH net-next] tipc: allow one link per bearer to neighboring nodes
Date: Fri, 14 Nov 2014 18:33:19 +0100
Message-ID: <1415986399-23874-1-git-send-email-holger.brunck@keymile.com>
Cc: jon.maloy@ericsson.com, Holger Brunck <holger.brunck@keymile.com>,
	Ying Xue <ying.xue@windriver.com>,
	Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:33861 "EHLO
	mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161175AbaKNRjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 12:39:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no reason to limit the amount of possible links to a
neighboring node to 2. If we have more then two bearers we can also
establish more links.

Signed-off-by: Holger Brunck <holger.brunck@keymile.com>
Reviewed-By: Jon Maloy <jon.maloy@ericsson.com>
cc: Ying Xue <ying.xue@windriver.com>
cc: Erik Hugne <erik.hugne@ericsson.com>
cc: netdev@vger.kernel.org
---
 net/tipc/link.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 1db162a..7cf8004 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -224,9 +224,10 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 	char addr_string[16];
 	u32 peer = n_ptr->addr;
 
-	if (n_ptr->link_cnt >= 2) {
+	if (n_ptr->link_cnt >= MAX_BEARERS) {
 		tipc_addr_string_fill(addr_string, n_ptr->addr);
-		pr_err("Attempt to establish third link to %s\n", addr_string);
+		pr_err("Attempt to establish %uth link to %s. Max %u allowed.\n",
+			n_ptr->link_cnt, addr_string, MAX_BEARERS);
 		return NULL;
 	}
 
-- 
2.1.2
