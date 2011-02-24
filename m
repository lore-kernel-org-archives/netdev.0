From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 11/17] tipc: Set unused probe field of link protocol messages to defined value
Date: Wed, 23 Feb 2011 20:26:39 -0500
Message-ID: <1298510805-20630-12-git-send-email-paul.gortmaker@windriver.com>
References: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com, netdev@vger.kernel.org,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34519 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932119Ab1BXB1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 20:27:13 -0500
In-Reply-To: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Ensures that a link reset or activate message has a "probe" field
of zero. (This field is currently unused in these messages, but this
could potentially change in future versions of TIPC.)

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index d1818fb..754e310 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1946,6 +1946,7 @@ void tipc_link_send_proto_msg(struct link *l_ptr, u32 msg_typ, int probe_msg,
 		msg_set_ack(msg, mod(l_ptr->reset_checkpoint - 1));
 		msg_set_seq_gap(msg, 0);
 		msg_set_next_sent(msg, 1);
+		msg_set_probe(msg, 0);
 		msg_set_link_tolerance(msg, l_ptr->tolerance);
 		msg_set_linkprio(msg, l_ptr->priority);
 		msg_set_max_pkt(msg, l_ptr->max_pkt_target);
-- 
1.7.3.3

