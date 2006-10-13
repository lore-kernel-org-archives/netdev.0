From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 11/14] [TIPC] Can now list multicast link on an isolated network node
Date: Fri, 13 Oct 2006 13:37:52 +0200
Message-ID: <11607394753889-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:56972 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1751407AbWJMLiD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 07:38:03 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

This patch fixes a minor bug that prevents "tipc-config -l" from
displaying the multicast link if a TIPC node has never successfully
established at least one unicast link.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/node.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index fc6d096..886bda5 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -648,7 +648,7 @@ struct sk_buff *tipc_node_get_links(cons
 		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
 						   " (network address)");
 
-        if (!tipc_nodes)
+        if (tipc_mode != TIPC_NET_MODE)
                 return tipc_cfg_reply_none();
 	
 	/* Get space for all unicast links + multicast link */
-- 
1.4.1

