From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 09/10] batman-adv: remove broadcast packets scheduled for purged outgoing if
Date: Fri, 14 Aug 2015 22:57:13 +0200
Message-ID: <1439585834-26564-10-git-send-email-antonio@meshcoding.com>
References: <1439585834-26564-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:47576 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752066AbbHNU5o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Aug 2015 16:57:44 -0400
In-Reply-To: <1439585834-26564-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

When an interface is purged, the broadcast packets scheduled for this
interface should get purged as well.

Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/send.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 0a01992..191076e 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -616,7 +616,8 @@ batadv_purge_outstanding_packets(struct batadv_priv *bat_priv,
 		 * we delete only packets belonging to the given interface
 		 */
 		if ((hard_iface) &&
-		    (forw_packet->if_incoming != hard_iface))
+		    (forw_packet->if_incoming != hard_iface) &&
+		    (forw_packet->if_outgoing != hard_iface))
 			continue;
 
 		spin_unlock_bh(&bat_priv->forw_bcast_list_lock);
-- 
2.5.0
