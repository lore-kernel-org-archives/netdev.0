From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 01/28] tipc: Remove obsolete manipulation of message re-route count field
Date: Sat, 17 Sep 2011 23:31:57 -0400
Message-ID: <1316316744-29514-2-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49957 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753271Ab1IRDcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:32:42 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Eliminates code that increments and validates the re-route count field
of payload messages, since the elimination of multi-cluster support
means that it is no longer necessary for TIPC to forward incoming messages
to another node. (The obsolete code was incorrect anyway, since it
incorrectly incremented the re-route count field of messages that
originated on the node that forwarded the message.)

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/net.c |   11 -----------
 1 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/net/tipc/net.c b/net/tipc/net.c
index 68b3dd6..fafef6c 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -141,17 +141,6 @@ void tipc_net_route_msg(struct sk_buff *buf)
 		return;
 	msg = buf_msg(buf);
 
-	msg_incr_reroute_cnt(msg);
-	if (msg_reroute_cnt(msg) > 6) {
-		if (msg_errcode(msg)) {
-			buf_discard(buf);
-		} else {
-			tipc_reject_msg(buf, msg_destport(msg) ?
-					TIPC_ERR_NO_PORT : TIPC_ERR_NO_NAME);
-		}
-		return;
-	}
-
 	/* Handle message for this node */
 	dnode = msg_short(msg) ? tipc_own_addr : msg_destnode(msg);
 	if (tipc_in_scope(dnode, tipc_own_addr)) {
-- 
1.7.4.4
