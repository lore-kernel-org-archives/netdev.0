From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 08/10] net: unexport netdev_fix_features()
Date: Thu, 14 Jul 2011 02:10:30 +0200 (CEST)
Message-ID: <b2877ef353e9d00ea213ed1f03ee33fef63e3be5.1310601401.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:59824 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752852Ab1GNAKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2011 20:10:32 -0400
In-Reply-To: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is not used anywhere except net/core/dev.c now.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/netdevice.h |    1 -
 net/core/dev.c            |    3 +--
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ebace1b..c91c643 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2535,7 +2535,6 @@ static inline u32 netdev_get_wanted_features(stru=
ct net_device *dev)
 	return (dev->features & ~dev->hw_features) | dev->wanted_features;
 }
 u32 netdev_increment_features(u32 all, u32 one, u32 mask);
-u32 netdev_fix_features(struct net_device *dev, u32 features);
 int __netdev_update_features(struct net_device *dev);
 void netdev_update_features(struct net_device *dev);
 void netdev_change_features(struct net_device *dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index 09ce52c..a2f58ea 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5209,7 +5209,7 @@ static void rollback_registered(struct net_device=
 *dev)
 	list_del(&single);
 }
=20
-u32 netdev_fix_features(struct net_device *dev, u32 features)
+static u32 netdev_fix_features(struct net_device *dev, u32 features)
 {
 	/* Fix illegal checksum combinations */
 	if ((features & NETIF_F_HW_CSUM) &&
@@ -5262,7 +5262,6 @@ u32 netdev_fix_features(struct net_device *dev, u=
32 features)
=20
 	return features;
 }
-EXPORT_SYMBOL(netdev_fix_features);
=20
 int __netdev_update_features(struct net_device *dev)
 {
--=20
1.7.5.4

