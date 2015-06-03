From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 08/12] batman-adv: Remove unnecessary check for orig_ifinfo not NULL
Date: Wed,  3 Jun 2015 16:14:04 +0200
Message-ID: <1433340848-1682-9-git-send-email-antonio@meshcoding.com>
References: <1433340848-1682-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:27703 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932631AbbFCOQW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 10:16:22 -0400
In-Reply-To: <1433340848-1682-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

orig_ifinfo is dereferenced multiple times in batadv_iv_ogm_update_seqnos
before the check for NULL is done. The function also exists at the
beginning when orig_ifinfo would have been NULL. This makes the check at
the end unnecessary and only confuses the reader/code analyzers.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 9f83137..4e93d2d 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1357,8 +1357,7 @@ batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 out:
 	spin_unlock_bh(&orig_node->bat_iv.ogm_cnt_lock);
 	batadv_orig_node_free_ref(orig_node);
-	if (orig_ifinfo)
-		batadv_orig_ifinfo_free_ref(orig_ifinfo);
+	batadv_orig_ifinfo_free_ref(orig_ifinfo);
 	return ret;
 }
 
-- 
2.4.2
