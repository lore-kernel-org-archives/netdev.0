From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next 1/5] tipc: only create header copy for name distr messages
Date: Thu, 26 Feb 2015 07:43:26 +0100
Message-ID: <1424933010-31003-2-git-send-email-erik.hugne@ericsson.com>
References: <1424933010-31003-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
	<richard.alpe@ericsson.com>, <ying.xue@windriver.com>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:60882 "EHLO
	sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983AbbBZGrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 01:47:40 -0500
In-Reply-To: <1424933010-31003-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

The TIPC name distributor pushes topology updates to the cluster
neighbors. Currently this is done in a unicast manner, and the
skb holding the update is cloned for each cluster member. This
is unnecessary, as we only modify the destnode field in the header
so we change it to do pskb_copy instead.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/name_distr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index fcb0791..506aaa5 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -98,7 +98,7 @@ void named_cluster_distribute(struct net *net, struct sk_buff *skb)
 			continue;
 		if (!tipc_node_active_links(node))
 			continue;
-		oskb = skb_copy(skb, GFP_ATOMIC);
+		oskb = pskb_copy(skb, GFP_ATOMIC);
 		if (!oskb)
 			break;
 		msg_set_destnode(buf_msg(oskb), dnode);
-- 
2.1.4
