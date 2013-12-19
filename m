From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 6/6] batman-adv: fix alignment for batadv_tvlv_tt_change
Date: Thu, 19 Dec 2013 01:15:32 +0100
Message-ID: <1387412132-889-7-git-send-email-antonio@meshcoding.com>
References: <1387412132-889-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:2070 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751922Ab3LSASF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 19:18:05 -0500
In-Reply-To: <1387412132-889-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make struct batadv_tvlv_tt_change a multiple 4 bytes long
to avoid padding on any architecture.

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/packet.h            | 4 ++--
 net/batman-adv/translation-table.c | 6 ++++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 04cf27c..2dd8f24 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -484,13 +484,13 @@ struct batadv_tvlv_tt_vlan_data {
  * struct batadv_tvlv_tt_change - translation table diff data
  * @flags: status indicators concerning the non-mesh client (see
  *  batadv_tt_client_flags)
- * @reserved: reserved field
+ * @reserved: reserved field - useful for alignment purposes only
  * @addr: mac address of non-mesh client that triggered this tt change
  * @vid: VLAN identifier
  */
 struct batadv_tvlv_tt_change {
 	uint8_t flags;
-	uint8_t reserved;
+	uint8_t reserved[3];
 	uint8_t addr[ETH_ALEN];
 	__be16 vid;
 };
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 4add57d..ff625fe 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -333,7 +333,8 @@ static void batadv_tt_local_event(struct batadv_priv *bat_priv,
 		return;
 
 	tt_change_node->change.flags = flags;
-	tt_change_node->change.reserved = 0;
+	memset(tt_change_node->change.reserved, 0,
+	       sizeof(tt_change_node->change.reserved));
 	memcpy(tt_change_node->change.addr, common->addr, ETH_ALEN);
 	tt_change_node->change.vid = htons(common->vid);
 
@@ -2221,7 +2222,8 @@ static void batadv_tt_tvlv_generate(struct batadv_priv *bat_priv,
 			       ETH_ALEN);
 			tt_change->flags = tt_common_entry->flags;
 			tt_change->vid = htons(tt_common_entry->vid);
-			tt_change->reserved = 0;
+			memset(tt_change->reserved, 0,
+			       sizeof(tt_change->reserved));
 
 			tt_num_entries++;
 			tt_change++;
-- 
1.8.5.1
