From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 3/4] net: Fix ETHTOOL_GFEATURES compatibility
Date: Wed, 23 Feb 2011 03:52:28 +0100 (CET)
Message-ID: <901aca0071da9f2fb1d46080441501309f210fb2.1298429033.git.mirq-linux@rere.qmqm.pl>
References: <cover.1298429033.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:47058 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751739Ab1BWCwa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Feb 2011 21:52:30 -0500
In-Reply-To: <cover.1298429033.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement getting rx checksum state for not updated drivers.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/core/ethtool.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 66cdc76..69a3edc 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -168,6 +168,18 @@ EXPORT_SYMBOL(ethtool_ntuple_flush);
=20
 #define ETHTOOL_DEV_FEATURE_WORDS	1
=20
+static void ethtool_get_features_compat(struct net_device *dev,
+	struct ethtool_get_features_block *features)
+{
+	if (!dev->ethtool_ops)
+		return;
+
+	/* getting RX checksum */
+	if (dev->ethtool_ops->get_rx_csum)
+		if (dev->ethtool_ops->get_rx_csum(dev))
+			features[0].active |=3D NETIF_F_RXCSUM;
+}
+
 static int ethtool_get_features(struct net_device *dev, void __user *u=
seraddr)
 {
 	struct ethtool_gfeatures cmd =3D {
@@ -185,6 +197,8 @@ static int ethtool_get_features(struct net_device *=
dev, void __user *useraddr)
 	u32 __user *sizeaddr;
 	u32 copy_size;
=20
+	ethtool_get_features_compat(dev, features);
+
 	sizeaddr =3D useraddr + offsetof(struct ethtool_gfeatures, size);
 	if (get_user(copy_size, sizeaddr))
 		return -EFAULT;
--=20
1.7.2.3

