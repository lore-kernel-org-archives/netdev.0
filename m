From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 2/6] batman-adv: Don't return value in void function
Date: Thu,  9 Jun 2011 23:09:10 +0200
Message-ID: <1307653754-5014-3-git-send-email-sven@narfation.org>
References: <1307653754-5014-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:56880 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755156Ab1FIVJS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 17:09:18 -0400
In-Reply-To: <1307653754-5014-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gw_node_delete is defined with "void" as return type, but still tries to
return a value. The called function gw_node_delete is also return as
void and thus doesn't provide a value for us.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/gateway_client.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index ab597c4..cf7f95e 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -352,7 +352,7 @@ unlock:
 
 void gw_node_delete(struct bat_priv *bat_priv, struct orig_node *orig_node)
 {
-	return gw_node_update(bat_priv, orig_node, 0);
+	gw_node_update(bat_priv, orig_node, 0);
 }
 
 void gw_node_purge(struct bat_priv *bat_priv)
-- 
1.7.5.3

