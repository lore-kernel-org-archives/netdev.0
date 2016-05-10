From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 17/17] batman-adv: use batadv_compare_eth when possible
Date: Wed, 11 May 2016 03:30:05 +0800
Message-ID: <1462908605-27412-18-git-send-email-a@unstable.cc>
References: <1462908605-27412-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <a@unstable.cc>,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:19658 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752442AbcEJTjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 15:39:22 -0400
In-Reply-To: <1462908605-27412-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When comparing Ethernet address it is better to use the more
generic batadv_compare_eth. The latter is also optimised for
architectures having a fast unaligned access.

Signed-off-by: Antonio Quartulli <a@unstable.cc>
[sven@narfation.org: fix conflicts with current version]
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/network-coding.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index df5ae9c7e507..678f06865312 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -521,12 +521,10 @@ static bool batadv_nc_hash_compare(const struct hlist_node *node,
 	nc_path2 = data2;
 
 	/* Return 1 if the two keys are identical */
-	if (memcmp(nc_path1->prev_hop, nc_path2->prev_hop,
-		   sizeof(nc_path1->prev_hop)) != 0)
+	if (!batadv_compare_eth(nc_path1->prev_hop, nc_path2->prev_hop))
 		return false;
 
-	if (memcmp(nc_path1->next_hop, nc_path2->next_hop,
-		   sizeof(nc_path1->next_hop)) != 0)
+	if (!batadv_compare_eth(nc_path1->next_hop, nc_path2->next_hop))
 		return false;
 
 	return true;
-- 
2.8.2
