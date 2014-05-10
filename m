From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 1/4] batman-adv: fix neigh_ifinfo imbalance
Date: Sat, 10 May 2014 17:35:07 +0200
Message-ID: <1399736110-22333-2-git-send-email-antonio@meshcoding.com>
References: <1399736110-22333-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:21495 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410AbaEJPgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 May 2014 11:36:31 -0400
In-Reply-To: <1399736110-22333-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

The neigh_ifinfo object must be freed if it has been used in
batadv_iv_ogm_process_per_outif().

This is a regression introduced by
89652331c00f43574515059ecbf262d26d885717
("batman-adv: split tq information in neigh_node struct")

Reported-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index b3bd4ec..f04224c 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1545,6 +1545,8 @@ out_neigh:
 	if ((orig_neigh_node) && (!is_single_hop_neigh))
 		batadv_orig_node_free_ref(orig_neigh_node);
 out:
+	if (router_ifinfo)
+		batadv_neigh_ifinfo_free_ref(router_ifinfo);
 	if (router)
 		batadv_neigh_node_free_ref(router);
 	if (router_router)
-- 
1.8.5.5
