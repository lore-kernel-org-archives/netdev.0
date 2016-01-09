From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 11/16] batman-adv: Split a condition check
Date: Sat,  9 Jan 2016 21:20:16 +0800
Message-ID: <1452345621-15908-12-git-send-email-a@unstable.cc>
References: <1452345621-15908-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Markus Elfring <elfring@users.sourceforge.net>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:39868 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752780AbcAINkR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jan 2016 08:40:17 -0500
In-Reply-To: <1452345621-15908-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>

Let us split a check for a condition at the beginning of the
batadv_is_ap_isolated() function so that a direct return can be performed
in this function if the variable "vlan" contained a null pointer.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/translation-table.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 5852fda9f175..a22080c53401 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -3339,7 +3339,10 @@ bool batadv_is_ap_isolated(struct batadv_priv *bat_priv, u8 *src, u8 *dst,
 	bool ret = false;
 
 	vlan = batadv_softif_vlan_get(bat_priv, vid);
-	if (!vlan || !atomic_read(&vlan->ap_isolation))
+	if (!vlan)
+		return false;
+
+	if (!atomic_read(&vlan->ap_isolation))
 		goto out;
 
 	tt_local_entry = batadv_tt_local_hash_find(bat_priv, dst, vid);
-- 
2.7.0
