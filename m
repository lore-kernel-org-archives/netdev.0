From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 17/17] tipc: Avoid reliable broadcast preparation for NACK messages
Date: Wed, 23 Feb 2011 20:26:45 -0500
Message-ID: <1298510805-20630-18-git-send-email-paul.gortmaker@windriver.com>
References: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com, netdev@vger.kernel.org,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34546 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932155Ab1BXB1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 20:27:19 -0500
In-Reply-To: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Enhance TIPC to skip unnecessary (and, in some cases, redundant)
preparation work when sending a broadcast link NACK message, since this
preparation is only required for broadcast messages that are sent in a
reliable manner. This change also fixes a bug that caused NACK messages
to be improperly counted as "TX packets" in TIPC's broadcast link
statistics.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 63df42b..7dc1dc7 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -298,6 +298,7 @@ static void bclink_send_nack(struct tipc_node *n_ptr)
 		msg = buf_msg(buf);
 		tipc_msg_init(msg, BCAST_PROTOCOL, STATE_MSG,
 			 INT_H_SIZE, n_ptr->addr);
+		msg_set_non_seq(msg, 1);
 		msg_set_mc_netid(msg, tipc_net_id);
 		msg_set_bcast_ack(msg, mod(n_ptr->bclink.last_in));
 		msg_set_bcgap_after(msg, n_ptr->bclink.gap_after);
-- 
1.7.3.3

