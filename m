From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next] tipc: fix out of bounds indexing
Date: Mon, 28 Apr 2014 08:20:09 +0200
Message-ID: <1398666009-1334-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ying.xue@windriver.com>, <paul.gortmaker@windriver.com>,
	<richard.alpe@ericsson.com>, Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <maloy@donjonn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:43536 "EHLO
	sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753340AbaD1GT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 02:19:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

Commit 78acb1f9b898e85fa2c1e28e700b54b66b288e8d ("tipc: add
ioctl to fetch link names") introduced a buffer overflow bug where
specially crafted ioctl requests could cause out-of-bounds indexing
of the node->links array. This was caused by an incorrect check vs
MAX_BEARERS, and the static code checker complaint is:
net/tipc/node.c:459 tipc_node_get_linkname() error: buffer overflow 'node->links' 2 <= 2

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 net/tipc/node.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 1f938f3..6d6543e 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -453,7 +453,7 @@ int tipc_node_get_linkname(u32 bearer_id, u32 addr, char *linkname, size_t len)
 	struct tipc_link *link;
 	struct tipc_node *node = tipc_node_find(addr);
 
-	if ((bearer_id > MAX_BEARERS) || !node)
+	if ((bearer_id >= MAX_BEARERS) || !node)
 		return -EINVAL;
 	tipc_node_lock(node);
 	link = node->links[bearer_id];
-- 
1.8.3.2
