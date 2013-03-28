From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 05/11] batman-adv: rename batadv_softif_destroy to reflect sysfs use case
Date: Thu, 28 Mar 2013 08:50:25 +0100
Message-ID: <1364457031-3194-6-git-send-email-ordex@autistici.org>
References: <1364457031-3194-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:33323 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756664Ab3C1HwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 03:52:10 -0400
In-Reply-To: <1364457031-3194-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
CC: Sven Eckelmann <sven@narfation.org>
Acked-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/hard-interface.c | 2 +-
 net/batman-adv/soft-interface.c | 6 +++++-
 net/batman-adv/soft-interface.h | 2 +-
 3 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 74e3ec2f..6c32607 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -448,7 +448,7 @@ void batadv_hardif_disable_interface(struct batadv_hard_iface *hard_iface,
 
 	/* nobody uses this interface anymore */
 	if (!bat_priv->num_ifaces && autodel == BATADV_IF_CLEANUP_AUTO)
-		batadv_softif_destroy(hard_iface->soft_iface);
+		batadv_softif_destroy_sysfs(hard_iface->soft_iface);
 
 	hard_iface->soft_iface = NULL;
 	batadv_hardif_free_ref(hard_iface);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index e889bfb..bc77a5be 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -581,7 +581,11 @@ struct net_device *batadv_softif_create(const char *name)
 	return soft_iface;
 }
 
-void batadv_softif_destroy(struct net_device *soft_iface)
+/**
+ * batadv_softif_destroy_sysfs - deletion of batadv_soft_interface via sysfs
+ * @soft_iface: the to-be-removed batman-adv interface
+ */
+void batadv_softif_destroy_sysfs(struct net_device *soft_iface)
 {
 	struct batadv_priv *bat_priv = netdev_priv(soft_iface);
 
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interface.h
index 43182e5..49bc66b 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -25,7 +25,7 @@ void batadv_interface_rx(struct net_device *soft_iface,
 			 struct sk_buff *skb, struct batadv_hard_iface *recv_if,
 			 int hdr_size, struct batadv_orig_node *orig_node);
 struct net_device *batadv_softif_create(const char *name);
-void batadv_softif_destroy(struct net_device *soft_iface);
+void batadv_softif_destroy_sysfs(struct net_device *soft_iface);
 int batadv_softif_is_valid(const struct net_device *net_dev);
 
 #endif /* _NET_BATMAN_ADV_SOFT_INTERFACE_H_ */
-- 
1.8.1.5
