From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 14/28] tipc: Remove obsolete congestion handling when sending a broadcast NACK
Date: Sat, 17 Sep 2011 23:32:10 -0400
Message-ID: <1316316744-29514-15-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49984 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756304Ab1IRDcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:32:52 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Eliminates obsolete code that handles broadcast bearer congestion when
the broadast link sends a NACK message, since the broadcast pseudo-bearer
never becomes blocked.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index bead28b..28908f5 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -299,14 +299,9 @@ static void bclink_send_nack(struct tipc_node *n_ptr)
 		msg_set_bcgap_to(msg, n_ptr->bclink.gap_to);
 		msg_set_bcast_tag(msg, tipc_own_tag);
 
-		if (tipc_bearer_send(&bcbearer->bearer, buf, NULL)) {
-			bcl->stats.sent_nacks++;
-			buf_discard(buf);
-		} else {
-			tipc_bearer_schedule(bcl->b_ptr, bcl);
-			bcl->proto_msg_queue = buf;
-			bcl->stats.bearer_congs++;
-		}
+		tipc_bearer_send(&bcbearer->bearer, buf, NULL);
+		bcl->stats.sent_nacks++;
+		buf_discard(buf);
 
 		/*
 		 * Ensure we doesn't send another NACK msg to the node
-- 
1.7.4.4
