From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 6/32] [TIPC] Links now validate destination node specified by incoming messages.
Date: Thu, 22 Jun 2006 15:59:19 +0200
Message-ID: <1150984785826-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:41146 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1030638AbWFVN7u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:50 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

This fix prevents link flopping and name table inconsistency problems arising
when a node is assigned a different <Z.C.N> value than it used previously.
(Changing the <Z.C.N> value causes other nodes to have two link endpoints
sending to the same MAC address using two different destination <Z.C.N> values,
requiring the receiving node to filter out the unwanted messages.)

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/link.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 784b24b..955b87d 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1720,6 +1720,11 @@ #endif
 			link_recv_non_seq(buf);
 			continue;
 		}
+		
+		if (unlikely(!msg_short(msg) &&
+			     (msg_destnode(msg) != tipc_own_addr)))
+			goto cont;
+		
 		n_ptr = tipc_node_find(msg_prevnode(msg));
 		if (unlikely(!n_ptr))
 			goto cont;
-- 
1.4.0

