From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: introduce netdev_change_features()
Date: Sat,  7 May 2011 15:22:17 +0200 (CEST)
Message-ID: <20110507132217.0938E13A6A@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:37167 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753370Ab1EGNWS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 May 2011 09:22:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It will be needed by bonding and other drivers changing vlan_features
after ndo_init callback.

As a bonus, this includes kernel-doc for netdev_update_features().

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/netdevice.h |    1 +
 net/core/dev.c            |   25 +++++++++++++++++++++++++
 2 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d5de66a..686af72 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2560,6 +2560,7 @@ u32 netdev_increment_features(u32 all, u32 one, u=
32 mask);
 u32 netdev_fix_features(struct net_device *dev, u32 features);
 int __netdev_update_features(struct net_device *dev);
 void netdev_update_features(struct net_device *dev);
+void netdev_change_features(struct net_device *dev);
=20
 void netif_stacked_transfer_operstate(const struct net_device *rootdev=
,
 					struct net_device *dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index 44ef8f8..c91d14c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5287,6 +5287,14 @@ int __netdev_update_features(struct net_device *=
dev)
 	return 1;
 }
=20
+/**
+ *	netdev_update_features - recalculate device features
+ *	@dev: the device to check
+ *
+ *	Recalculate dev->features set and send notifications if it
+ *	has changed. Should be called after driver or hardware dependent
+ *	conditions might have changed that influence the features.
+ */
 void netdev_update_features(struct net_device *dev)
 {
 	if (__netdev_update_features(dev))
@@ -5295,6 +5303,23 @@ void netdev_update_features(struct net_device *d=
ev)
 EXPORT_SYMBOL(netdev_update_features);
=20
 /**
+ *	netdev_change_features - recalculate device features
+ *	@dev: the device to check
+ *
+ *	Recalculate dev->features set and send notifications even
+ *	if they have not changed. Should be called instead of
+ *	netdev_update_features() if also dev->vlan_features might
+ *	have changed to allow the changes to be propagated to stacked
+ *	VLAN devices.
+ */
+void netdev_change_features(struct net_device *dev)
+{
+	__netdev_update_features(dev);
+	netdev_features_change(dev);
+}
+EXPORT_SYMBOL(netdev_change_features);
+
+/**
  *	netif_stacked_transfer_operstate -	transfer operstate
  *	@rootdev: the root or lower level device to transfer state from
  *	@dev: the device to transfer operstate to
--=20
1.7.2.5

