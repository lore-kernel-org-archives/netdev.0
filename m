From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 2/4] tipc: don't check link reset on non existing link
Date: Thu, 3 Mar 2016 14:20:41 +0100
Message-ID: <1457011243-23605-2-git-send-email-richard.alpe@ericsson.com>
References: <1457011243-23605-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Richard Alpe <richard.alpe@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:54963 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753755AbcCCNUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 08:20:52 -0500
In-Reply-To: <1457011243-23605-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure we have a link before checking if it has been reset or not.

Prior to this patch tipc_link_is_reset() could be called with a non
existing link, resulting in a null pointer dereference.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@gmail.com>
---
 net/tipc/node.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index cdb7950..590d597 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -843,7 +843,7 @@ void tipc_node_check_dest(struct net *net, u32 onode,
 	memcpy(&le->maddr, maddr, sizeof(*maddr));
 exit:
 	tipc_node_write_unlock(n);
-	if (reset && !tipc_link_is_reset(l))
+	if (reset && l && !tipc_link_is_reset(l))
 		tipc_node_link_down(n, b->identity, false);
 	tipc_node_put(n);
 }
-- 
2.1.4
