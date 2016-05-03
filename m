From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 06/15] batman-adv: use to_delayed_work
Date: Wed,  4 May 2016 06:23:41 +0800
Message-ID: <1462314230-16257-7-git-send-email-a@unstable.cc>
References: <1462314230-16257-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Geliang Tang <geliangtang@163.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:20685 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756786AbcECWYo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 18:24:44 -0400
In-Reply-To: <1462314230-16257-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geliang Tang <geliangtang@163.com>

Use to_delayed_work() instead of open-coding it.

Signed-off-by: Geliang Tang <geliangtang@163.com>
Reviewed-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bridge_loop_avoidance.c | 2 +-
 net/batman-adv/distributed-arp-table.c | 2 +-
 net/batman-adv/network-coding.c        | 2 +-
 net/batman-adv/originator.c            | 2 +-
 net/batman-adv/send.c                  | 4 ++--
 net/batman-adv/translation-table.c     | 2 +-
 6 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 56bc971e404b..cad8cb3a88f2 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1303,7 +1303,7 @@ static void batadv_bla_periodic_work(struct work_struct *work)
 	struct batadv_hard_iface *primary_if;
 	int i;
 
-	delayed_work = container_of(work, struct delayed_work, work);
+	delayed_work = to_delayed_work(work);
 	priv_bla = container_of(delayed_work, struct batadv_priv_bla, work);
 	bat_priv = container_of(priv_bla, struct batadv_priv, bla);
 	primary_if = batadv_primary_if_get_selected(bat_priv);
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index ce574e9cef3b..33f273e5354b 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -152,7 +152,7 @@ static void batadv_dat_purge(struct work_struct *work)
 	struct batadv_priv_dat *priv_dat;
 	struct batadv_priv *bat_priv;
 
-	delayed_work = container_of(work, struct delayed_work, work);
+	delayed_work = to_delayed_work(work);
 	priv_dat = container_of(delayed_work, struct batadv_priv_dat, work);
 	bat_priv = container_of(priv_dat, struct batadv_priv, dat);
 
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index b41719b6487a..0d3bf4368e9b 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -714,7 +714,7 @@ static void batadv_nc_worker(struct work_struct *work)
 	struct batadv_priv *bat_priv;
 	unsigned long timeout;
 
-	delayed_work = container_of(work, struct delayed_work, work);
+	delayed_work = to_delayed_work(work);
 	priv_nc = container_of(delayed_work, struct batadv_priv_nc, work);
 	bat_priv = container_of(priv_nc, struct batadv_priv, nc);
 
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index e4cbb0753e37..5b802f0dc24b 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -1222,7 +1222,7 @@ static void batadv_purge_orig(struct work_struct *work)
 	struct delayed_work *delayed_work;
 	struct batadv_priv *bat_priv;
 
-	delayed_work = container_of(work, struct delayed_work, work);
+	delayed_work = to_delayed_work(work);
 	bat_priv = container_of(delayed_work, struct batadv_priv, orig_work);
 	_batadv_purge_orig(bat_priv);
 	queue_delayed_work(batadv_event_workqueue,
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 3ce06e0a91b1..20076b4c5e1d 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -552,7 +552,7 @@ static void batadv_send_outstanding_bcast_packet(struct work_struct *work)
 	struct net_device *soft_iface;
 	struct batadv_priv *bat_priv;
 
-	delayed_work = container_of(work, struct delayed_work, work);
+	delayed_work = to_delayed_work(work);
 	forw_packet = container_of(delayed_work, struct batadv_forw_packet,
 				   delayed_work);
 	soft_iface = forw_packet->if_incoming->soft_iface;
@@ -604,7 +604,7 @@ void batadv_send_outstanding_bat_ogm_packet(struct work_struct *work)
 	struct batadv_forw_packet *forw_packet;
 	struct batadv_priv *bat_priv;
 
-	delayed_work = container_of(work, struct delayed_work, work);
+	delayed_work = to_delayed_work(work);
 	forw_packet = container_of(delayed_work, struct batadv_forw_packet,
 				   delayed_work);
 	bat_priv = netdev_priv(forw_packet->if_incoming->soft_iface);
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 29fd62839fac..d44ce84626c5 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -3226,7 +3226,7 @@ static void batadv_tt_purge(struct work_struct *work)
 	struct batadv_priv_tt *priv_tt;
 	struct batadv_priv *bat_priv;
 
-	delayed_work = container_of(work, struct delayed_work, work);
+	delayed_work = to_delayed_work(work);
 	priv_tt = container_of(delayed_work, struct batadv_priv_tt, work);
 	bat_priv = container_of(priv_tt, struct batadv_priv, tt);
 
-- 
2.8.2
