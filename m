From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 12/28] tipc: Remove deferred queue head caching during broadcast message reception
Date: Sat, 17 Sep 2011 23:32:08 -0400
Message-ID: <1316316744-29514-13-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49979 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756292Ab1IRDcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:32:50 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Modifies TIPC's incoming broadcast packet handler so that it no longer
pre-reads information about the deferred packet queue, since the cached
value is unreliable once the associated node lock has been released.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index bc01ca6..8d29852 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -467,7 +467,6 @@ void tipc_bclink_recv_pkt(struct sk_buff *buf)
 	/* Handle in-sequence broadcast message */
 
 receive:
-	deferred = node->bclink.deferred_head;
 	next_in = mod(node->bclink.last_in + 1);
 	seqno = msg_seqno(msg);
 
@@ -500,6 +499,7 @@ receive:
 		}
 		buf = NULL;
 		tipc_node_lock(node);
+		deferred = node->bclink.deferred_head;
 		if (deferred && (buf_seqno(deferred) == mod(next_in + 1))) {
 			buf = deferred;
 			msg = buf_msg(buf);
-- 
1.7.4.4
