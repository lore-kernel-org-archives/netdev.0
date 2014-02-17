From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 02/10] batman-adv: fix TT-TVLV parsing on OGM reception
Date: Mon, 17 Feb 2014 21:48:41 +0100
Message-ID: <1392670129-2498-3-git-send-email-antonio@meshcoding.com>
References: <1392670129-2498-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:19653 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbaBQUw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 15:52:59 -0500
In-Reply-To: <1392670129-2498-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When accessing a TT-TVLV container in the OGM RX path
the variable pointing to the list of changes to apply is
altered by mistake.

This makes the TT component read data at the wrong position
in the OGM packet buffer.

Fix it by removing the bogus pointer alteration.

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/translation-table.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index b6071f6..beba13f 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -3218,7 +3218,6 @@ static void batadv_tt_update_orig(struct batadv_priv *bat_priv,
 
 		spin_lock_bh(&orig_node->tt_lock);
 
-		tt_change = (struct batadv_tvlv_tt_change *)tt_buff;
 		batadv_tt_update_changes(bat_priv, orig_node, tt_num_changes,
 					 ttvn, tt_change);
 
-- 
1.8.5.3
