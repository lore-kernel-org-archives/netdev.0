From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 13/14] batman-adv: remove broadcast packets scheduled for purged outgoing if
Date: Tue,  4 Aug 2015 18:35:33 +0200
Message-ID: <1438706134-3492-14-git-send-email-antonio__24655.9398751289$1438707334$gmane$org@meshcoding.com>
References: <1438706134-3492-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:26167 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754214AbbHDQzS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 12:55:18 -0400
In-Reply-To: <1438706134-3492-1-git-send-email-antonio@meshcoding.com>
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
