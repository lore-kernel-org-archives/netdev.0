From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 08/13] batman-adv: refactoring API: find generalized name for bat_ogm_init_primary callback
Date: Wed, 18 Apr 2012 12:00:05 +0200
Message-ID: <1334743210-12338-9-git-send-email-ordex@autistici.org>
References: <1334743210-12338-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:24768 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752991Ab2DRJ7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 05:59:35 -0400
In-Reply-To: <1334743210-12338-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c     |    4 ++--
 net/batman-adv/hard-interface.c |    2 +-
 net/batman-adv/main.c           |    2 +-
 net/batman-adv/types.h          |    4 ++--
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 2714670..c0bdb90 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -67,7 +67,7 @@ static void bat_iv_ogm_iface_disable(struct hard_iface *hard_iface)
 	hard_iface->packet_buff = NULL;
 }
 
-static void bat_iv_ogm_init_primary(struct hard_iface *hard_iface)
+static void bat_iv_ogm_primary_iface_set(struct hard_iface *hard_iface)
 {
 	struct batman_ogm_packet *batman_ogm_packet;
 
@@ -1191,7 +1191,7 @@ static struct bat_algo_ops batman_iv __read_mostly = {
 	.name = "BATMAN IV",
 	.bat_iface_enable = bat_iv_ogm_iface_enable,
 	.bat_iface_disable = bat_iv_ogm_iface_disable,
-	.bat_ogm_init_primary = bat_iv_ogm_init_primary,
+	.bat_primary_iface_set = bat_iv_ogm_primary_iface_set,
 	.bat_ogm_update_mac = bat_iv_ogm_update_mac,
 	.bat_ogm_schedule = bat_iv_ogm_schedule,
 	.bat_ogm_emit = bat_iv_ogm_emit,
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 3b391fd..75a555b 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -146,7 +146,7 @@ static void primary_if_select(struct bat_priv *bat_priv,
 	if (!new_hard_iface)
 		goto out;
 
-	bat_priv->bat_algo_ops->bat_ogm_init_primary(new_hard_iface);
+	bat_priv->bat_algo_ops->bat_primary_iface_set(new_hard_iface);
 	primary_if_update_addr(bat_priv, curr_hard_iface);
 
 out:
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index a47a6ce..7913272 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -210,7 +210,7 @@ int bat_algo_register(struct bat_algo_ops *bat_algo_ops)
 	/* all algorithms must implement all ops (for now) */
 	if (!bat_algo_ops->bat_iface_enable ||
 	    !bat_algo_ops->bat_iface_disable ||
-	    !bat_algo_ops->bat_ogm_init_primary ||
+	    !bat_algo_ops->bat_primary_iface_set ||
 	    !bat_algo_ops->bat_ogm_update_mac ||
 	    !bat_algo_ops->bat_ogm_schedule ||
 	    !bat_algo_ops->bat_ogm_emit ||
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index dd78023..4d93aad 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -381,8 +381,8 @@ struct bat_algo_ops {
 	int (*bat_iface_enable)(struct hard_iface *hard_iface);
 	/* de-init routing info when hard-interface is disabled */
 	void (*bat_iface_disable)(struct hard_iface *hard_iface);
-	/* init primary OGM when primary interface is selected */
-	void (*bat_ogm_init_primary)(struct hard_iface *hard_iface);
+	/* called when primary interface is selected / changed */
+	void (*bat_primary_iface_set)(struct hard_iface *hard_iface);
 	/* init mac addresses of the OGM belonging to this hard-interface */
 	void (*bat_ogm_update_mac)(struct hard_iface *hard_iface);
 	/* prepare a new outgoing OGM for the send queue */
-- 
1.7.9.4
