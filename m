From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 3/3] batman-adv: avoid NULL dereferences and fix if check
Date: Sat, 20 Dec 2014 13:48:57 +0100
Message-ID: <1419079737-31107-4-git-send-email-sven@narfation.org>
References: <1419079737-31107-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, Antonio Quartulli <antonio@meshcoding.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:58307 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752961AbaLTM61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2014 07:58:27 -0500
In-Reply-To: <1419079737-31107-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>

Gateway having bandwidth_down equal to zero are not accepted
at all and so never added to the Gateway list.
For this reason checking the bandwidth_down member in
batadv_gw_out_of_range() is useless.

This is probably a copy/paste error and this check was supposed
to be "!gw_node" only. Moreover, the way the check is written
now may also lead to a NULL dereference.

Fix this by rewriting the if-condition properly.

Introduced by 414254e342a0d58144de40c3da777521ebaeeb07
("batman-adv: tvlv - gateway download/upload bandwidth container")

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
Reported-by: David Binderman <dcb314@hotmail.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
Problem is in the kernel since v3.13 and may be important for the stable tree.

 net/batman-adv/gateway_client.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 90cff58..e0bcf9e 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -810,7 +810,7 @@ bool batadv_gw_out_of_range(struct batadv_priv *bat_priv,
 		goto out;
 
 	gw_node = batadv_gw_node_get(bat_priv, orig_dst_node);
-	if (!gw_node->bandwidth_down == 0)
+	if (!gw_node)
 		goto out;
 
 	switch (atomic_read(&bat_priv->gw_mode)) {
-- 
2.1.4
