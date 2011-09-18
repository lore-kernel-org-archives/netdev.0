From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 15/28] tipc: Eliminate redundant check when sending messages
Date: Sat, 17 Sep 2011 23:32:11 -0400
Message-ID: <1316316744-29514-16-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49985 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756311Ab1IRDcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:32:52 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Eliminates code in tipc_send_buf_fast() that handles messages
sent to a destination on the current node, since the only caller
of the routine only passes in messages destined for other nodes.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index b43beea..bc655f4 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1032,9 +1032,6 @@ int tipc_send_buf_fast(struct sk_buff *buf, u32 destnode)
 	u32 selector = msg_origport(buf_msg(buf)) & 1;
 	u32 dummy;
 
-	if (destnode == tipc_own_addr)
-		return tipc_port_recv_msg(buf);
-
 	read_lock_bh(&tipc_net_lock);
 	n_ptr = tipc_node_find(destnode);
 	if (likely(n_ptr)) {
-- 
1.7.4.4
