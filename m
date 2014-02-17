From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 06/10] batman-adv: fix potential orig_node reference leak
Date: Mon, 17 Feb 2014 21:48:45 +0100
Message-ID: <1392670129-2498-7-git-send-email-antonio@meshcoding.com>
References: <1392670129-2498-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:33824 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753017AbaBQUxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 15:53:13 -0500
In-Reply-To: <1392670129-2498-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <sw@simonwunderlich.de>

Since batadv_orig_node_new() sets the refcount to two, assuming that
the calling function will use a reference for putting the orig_node into
a hash or similar, both references must be freed if initialization of
the orig_node fails. Otherwise that object may be leaked in that error
case.

Reported-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 094ae7c..42cbc0a 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -254,6 +254,8 @@ batadv_iv_ogm_orig_get(struct batadv_priv *bat_priv, const uint8_t *addr)
 free_bcast_own:
 	kfree(orig_node->bat_iv.bcast_own);
 free_orig_node:
+	/* free twice, as batadv_orig_node_new sets refcount to 2 */
+	batadv_orig_node_free_ref(orig_node);
 	batadv_orig_node_free_ref(orig_node);
 
 	return NULL;
-- 
1.8.5.3
