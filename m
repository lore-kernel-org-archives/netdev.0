From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 4/4] batman-adv: Fix invalid stack access in batadv_dat_select_candidates
Date: Mon,  7 Dec 2015 23:12:15 +0800
Message-ID: <1449501135-30438-5-git-send-email-antonio@meshcoding.com>
References: <1449501135-30438-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:22119 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964838AbbLGPOS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2015 10:14:18 -0500
In-Reply-To: <1449501135-30438-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@open-mesh.com>

batadv_dat_select_candidates provides an u32 to batadv_hash_dat but it
needs a batadv_dat_entry with at least ip and vid filled in.

Fixes: 3e26722bc9f2 ("batman-adv: make the Distributed ARP Table vlan aware")
Signed-off-by: Sven Eckelmann <sven@open-mesh.com>
Acked-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/distributed-arp-table.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 83bc1aa..a49c705 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -566,6 +566,7 @@ batadv_dat_select_candidates(struct batadv_priv *bat_priv, __be32 ip_dst)
 	int select;
 	batadv_dat_addr_t last_max = BATADV_DAT_ADDR_MAX, ip_key;
 	struct batadv_dat_candidate *res;
+	struct batadv_dat_entry dat;
 
 	if (!bat_priv->orig_hash)
 		return NULL;
@@ -575,7 +576,9 @@ batadv_dat_select_candidates(struct batadv_priv *bat_priv, __be32 ip_dst)
 	if (!res)
 		return NULL;
 
-	ip_key = (batadv_dat_addr_t)batadv_hash_dat(&ip_dst,
+	dat.ip = ip_dst;
+	dat.vid = 0;
+	ip_key = (batadv_dat_addr_t)batadv_hash_dat(&dat,
 						    BATADV_DAT_ADDR_MAX);
 
 	batadv_dbg(BATADV_DBG_DAT, bat_priv,
-- 
2.6.3
