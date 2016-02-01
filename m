From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 2/2] tipc: fix link priority propagation
Date: Mon, 1 Feb 2016 08:19:57 +0100
Message-ID: <1454311197-10948-2-git-send-email-richard.alpe@ericsson.com>
References: <1454311197-10948-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Richard Alpe <richard.alpe@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:42820 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962AbcBAHUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 02:20:25 -0500
In-Reply-To: <1454311197-10948-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently link priority changes isn't handled for active links. In
this patch we resolve this by changing our priority if the peer passes
a valid priority in a state message.

Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
---
 net/tipc/link.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index f156353..6f4a6d9 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1458,6 +1458,12 @@ static int tipc_link_proto_rcv(struct tipc_link *l, struct sk_buff *skb,
 		if (in_range(peers_tol, TIPC_MIN_LINK_TOL, TIPC_MAX_LINK_TOL))
 			l->tolerance = peers_tol;
 
+		if (peers_prio && in_range(peers_prio, TIPC_MIN_LINK_PRI,
+					   TIPC_MAX_LINK_PRI)) {
+			l->priority = peers_prio;
+			rc = tipc_link_fsm_evt(l, LINK_FAILURE_EVT);
+		}
+
 		l->silent_intv_cnt = 0;
 		l->stats.recv_states++;
 		if (msg_probe(hdr))
-- 
2.1.4
