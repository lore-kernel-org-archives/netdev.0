From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 05/21] tipc: Remove code to emulate loss of broadcast messages
Date: Tue, 10 May 2011 16:44:21 -0400
Message-ID: <1305060277-15600-6-git-send-email-paul.gortmaker@windriver.com>
References: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52303 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551Ab1EJUo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:44:59 -0400
In-Reply-To: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Eliminates optional code used to test TIPC's ability to recover
from lost broadcast messages. This code duplicates functionality
already provided by the network stack's QoS option "network emulator".

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |   18 ------------------
 1 files changed, 0 insertions(+), 18 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 7dc1dc7..08e3216 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -44,13 +44,6 @@
 
 #define BCLINK_WIN_DEFAULT 20		/* bcast link window size (default) */
 
-/*
- * Loss rate for incoming broadcast frames; used to test retransmission code.
- * Set to N to cause every N'th frame to be discarded; 0 => don't discard any.
- */
-
-#define TIPC_BCAST_LOSS_RATE 0
-
 /**
  * struct bcbearer_pair - a pair of bearers used by broadcast link
  * @primary: pointer to primary bearer
@@ -434,9 +427,6 @@ int tipc_bclink_send_msg(struct sk_buff *buf)
 
 void tipc_bclink_recv_pkt(struct sk_buff *buf)
 {
-#if (TIPC_BCAST_LOSS_RATE)
-	static int rx_count;
-#endif
 	struct tipc_msg *msg = buf_msg(buf);
 	struct tipc_node *node = tipc_node_find(msg_prevnode(msg));
 	u32 next_in;
@@ -470,14 +460,6 @@ void tipc_bclink_recv_pkt(struct sk_buff *buf)
 		return;
 	}
 
-#if (TIPC_BCAST_LOSS_RATE)
-	if (++rx_count == TIPC_BCAST_LOSS_RATE) {
-		rx_count = 0;
-		buf_discard(buf);
-		return;
-	}
-#endif
-
 	tipc_node_lock(node);
 receive:
 	deferred = node->bclink.deferred_head;
-- 
1.7.4.4

