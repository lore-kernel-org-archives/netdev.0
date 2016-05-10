From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 09/17] batman-adv: Use kref_get for batadv_tvlv_container_get
Date: Wed, 11 May 2016 03:29:57 +0800
Message-ID: <1462908605-27412-10-git-send-email-a@unstable.cc>
References: <1462908605-27412-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:46278 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752633AbcEJTbO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 15:31:14 -0400
In-Reply-To: <1462908605-27412-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

batadv_tvlv_container_get requires that tvlv.container_list_lock is held by
the caller. It is therefore not possible that an item in
tvlv.container_list has an reference counter of 0 and is still in the list

The kref_get function instead WARNs (with debug information) when the
reference counter would still be 0. This makes a bug in batman-adv better
visible because kref_get_unless_zero would have ignored this problem.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/main.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index c8d8bc78a518..5f2974bd1227 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -748,9 +748,7 @@ batadv_tvlv_container_get(struct batadv_priv *bat_priv, u8 type, u8 version)
 		if (tvlv_tmp->tvlv_hdr.version != version)
 			continue;
 
-		if (!kref_get_unless_zero(&tvlv_tmp->refcount))
-			continue;
-
+		kref_get(&tvlv_tmp->refcount);
 		tvlv = tvlv_tmp;
 		break;
 	}
-- 
2.8.2
