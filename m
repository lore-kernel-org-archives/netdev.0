From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 15/17] batman-adv: use is_broadcast_ether_addr() instead of compare_eth(.., brd_addr)
Date: Mon, 30 May 2011 09:23:00 +0200
Message-ID: <1306740182-2665-16-git-send-email-sven@narfation.org>
References: <1306740182-2665-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:60263 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755240Ab1E3HXX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 May 2011 03:23:23 -0400
In-Reply-To: <1306740182-2665-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>

Instead of comparing mac addresses with the broadcast address by means
of compare_eth(), the is_broadcast_ether_addr() kernel function has to be
used.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Acked-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/routing.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 07f23ba..90ae6f0 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -661,7 +661,7 @@ void receive_bat_packet(const struct ethhdr *ethhdr,
 				hard_iface->net_dev->dev_addr))
 			is_my_oldorig = 1;
 
-		if (compare_eth(ethhdr->h_source, broadcast_addr))
+		if (is_broadcast_ether_addr(ethhdr->h_source))
 			is_broadcast = 1;
 	}
 	rcu_read_unlock();
-- 
1.7.5.3

