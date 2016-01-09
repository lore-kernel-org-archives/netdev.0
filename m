From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 02/16] batman-adv: Fix lockdep annotation of batadv_tlv_container_remove
Date: Sat,  9 Jan 2016 21:20:07 +0800
Message-ID: <1452345621-15908-3-git-send-email-a__49770.9259194837$1452345762$gmane$org@unstable.cc>
References: <1452345621-15908-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:23192 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754490AbcAINWT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jan 2016 08:22:19 -0500
In-Reply-To: <1452345621-15908-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@open-mesh.com>

The function handles tlv containers and not tlv handlers. Thus the
lockdep_assert_held has to check for the container_list lock.

Fixes: 2c72d655b044 ("batman-adv: Annotate deleting functions with external lock via lockdep")
Signed-off-by: Sven Eckelmann <sven@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 5dbcb2e2b497..95fd418e9567 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -747,7 +747,7 @@ static u16 batadv_tvlv_container_list_size(struct batadv_priv *bat_priv)
 static void batadv_tvlv_container_remove(struct batadv_priv *bat_priv,
 					 struct batadv_tvlv_container *tvlv)
 {
-	lockdep_assert_held(&bat_priv->tvlv.handler_list_lock);
+	lockdep_assert_held(&bat_priv->tvlv.container_list_lock);
 
 	if (!tvlv)
 		return;
-- 
2.7.0
