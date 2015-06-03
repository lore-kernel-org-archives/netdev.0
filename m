From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 09/12] batman-adv: main, Convert is_my_mac() to bool
Date: Wed,  3 Jun 2015 16:14:05 +0200
Message-ID: <1433340848-1682-10-git-send-email-antonio@meshcoding.com>
References: <1433340848-1682-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Markus Pargmann <mpa@pengutronix.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:6690 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932649AbbFCOQY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 10:16:24 -0400
In-Reply-To: <1433340848-1682-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Pargmann <mpa@pengutronix.de>

It is much clearer to see a bool type as return value than 'int' for
functions that are supposed to return true or false.

Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/main.c | 11 +++++++----
 net/batman-adv/main.h |  2 +-
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index fd9333d..a22247a 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -209,10 +209,13 @@ void batadv_mesh_free(struct net_device *soft_iface)
  * interfaces in the current mesh
  * @bat_priv: the bat priv with all the soft interface information
  * @addr: the address to check
+ *
+ * Returns 'true' if the mac address was found, false otherwise.
  */
-int batadv_is_my_mac(struct batadv_priv *bat_priv, const uint8_t *addr)
+bool batadv_is_my_mac(struct batadv_priv *bat_priv, const uint8_t *addr)
 {
 	const struct batadv_hard_iface *hard_iface;
+	bool is_my_mac = false;
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
@@ -223,12 +226,12 @@ int batadv_is_my_mac(struct batadv_priv *bat_priv, const uint8_t *addr)
 			continue;
 
 		if (batadv_compare_eth(hard_iface->net_dev->dev_addr, addr)) {
-			rcu_read_unlock();
-			return 1;
+			is_my_mac = true;
+			break;
 		}
 	}
 	rcu_read_unlock();
-	return 0;
+	return is_my_mac;
 }
 
 /**
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 026ba37..96876d2 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -195,7 +195,7 @@ extern struct workqueue_struct *batadv_event_workqueue;
 
 int batadv_mesh_init(struct net_device *soft_iface);
 void batadv_mesh_free(struct net_device *soft_iface);
-int batadv_is_my_mac(struct batadv_priv *bat_priv, const uint8_t *addr);
+bool batadv_is_my_mac(struct batadv_priv *bat_priv, const uint8_t *addr);
 struct batadv_hard_iface *
 batadv_seq_print_text_primary_if_get(struct seq_file *seq);
 int batadv_max_header_len(void);
-- 
2.4.2
