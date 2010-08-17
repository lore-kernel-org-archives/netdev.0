From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 08/14] tipc: Fix bug in broadcast link transmit statistics computation
Date: Tue, 17 Aug 2010 17:00:10 -0400
Message-ID: <1282078816-11844-9-git-send-email-paul.gortmaker@windriver.com>
References: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57133 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910Ab0HQVA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 17:00:26 -0400
In-Reply-To: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Modify TIPC's broadcast link so that it counts each piece of a
fragmented message individually, rather than as treating the group
as a single message.  This ensures that proper correlation of sent
and received traffic can be done when the broadcast link statistics
are displayed, and is consistent with the way fragments are counted
by TIPC's unicast links.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index eefdd1a..b11248c 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -409,10 +409,8 @@ int tipc_bclink_send_msg(struct sk_buff *buf)
 	res = tipc_link_send_buf(bcl, buf);
 	if (unlikely(res == -ELINKCONG))
 		buf_discard(buf);
-	else {
-		bcl->stats.sent_info++;
+	else
 		bclink_set_last_sent();
-	}
 
 	if (bcl->out_queue_size > bcl->stats.max_queue_sz)
 		bcl->stats.max_queue_sz = bcl->out_queue_size;
@@ -578,6 +576,7 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 		msg = buf_msg(buf);
 		msg_set_non_seq(msg, 1);
 		msg_set_mc_netid(msg, tipc_net_id);
+		bcl->stats.sent_info++;
 	}
 
 	/* Send buffer over bearers until all targets reached */
-- 
1.7.2.1

