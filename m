From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: Fix dev dev_ethtool_get_rx_csum() for forced NETIF_F_RXCSUM
Date: Thu, 31 Mar 2011 11:58:08 +0200 (CEST)
Message-ID: <f658c6e20dad946b50fda008c120a0347ad58314.1301565174.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:50167 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757164Ab1CaJ6M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2011 05:58:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_ethtool_get_rx_csum() won't report rx checksumming when it's not
changeable and driver is converted to hw_features and friends. Fix this=
=2E

(dev->hw_features & NETIF_F_RXCSUM) check is dropped - if the
ethtool_ops->get_rx_csum is set, then driver is not coverted, yet.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
[this is a fix also for 2.6.39]

 include/linux/netdevice.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5eeb2cd..0249fe7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2598,8 +2598,8 @@ static inline int dev_ethtool_get_settings(struct=
 net_device *dev,
=20
 static inline u32 dev_ethtool_get_rx_csum(struct net_device *dev)
 {
-	if (dev->hw_features & NETIF_F_RXCSUM)
-		return !!(dev->features & NETIF_F_RXCSUM);
+	if (dev->features & NETIF_F_RXCSUM)
+		return 1;
 	if (!dev->ethtool_ops || !dev->ethtool_ops->get_rx_csum)
 		return 0;
 	return dev->ethtool_ops->get_rx_csum(dev);
--=20
1.7.2.5

