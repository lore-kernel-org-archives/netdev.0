From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFT PATCH 8/9] net: extend netdev_features_t to 64 bits
Date: Mon, 20 Jun 2011 21:14:55 +0200 (CEST)
Message-ID: <8a12bc0824bce3b0678fcb68503cfaca97378c61.1308596963.git.mirq-linux@rere.qmqm.pl>
References: <cover.1308596962.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:41919 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753479Ab1FTTPA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 15:15:00 -0400
In-Reply-To: <cover.1308596962.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/netdev_features.h |    2 +-
 net/core/dev.c                  |   10 +++++-----
 net/core/net-sysfs.c            |    3 ++-
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_fea=
tures.h
index 2361e3ee..86d6193 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -12,7 +12,7 @@
=20
 #include <linux/types.h>
=20
-typedef u32 netdev_features_t;
+typedef u64 netdev_features_t;
=20
 enum {
 	NETIF_F_SG_BIT,			/* Scatter/gather IO. */
diff --git a/net/core/dev.c b/net/core/dev.c
index a5a0e76..7e58353 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5271,18 +5271,18 @@ int __netdev_update_features(struct net_device =
*dev)
 	if (dev->features =3D=3D features)
 		return 0;
=20
-	BUILD_BUG_ON(sizeof(features) !=3D sizeof(u32));	/* XXX: need: %Fx */
+	BUILD_BUG_ON(sizeof(features) !=3D sizeof(u64));	/* XXX: need: %Fx */
=20
-	netdev_dbg(dev, "Features changed: 0x%08x -> 0x%08x\n",
-		(u32)dev->features, (u32)features);
+	netdev_dbg(dev, "Features changed: 0x%016llx -> 0x%016llx\n",
+		(u64)dev->features, (u64)features);
=20
 	if (dev->netdev_ops->ndo_set_features)
 		err =3D dev->netdev_ops->ndo_set_features(dev, features);
=20
 	if (unlikely(err < 0)) {
 		netdev_err(dev,
-			"set_features() failed (%d); wanted 0x%08x, left 0x%08x\n",
-			err, (u32)features, (u32)dev->features);
+			"set_features() failed (%d); wanted 0x%016llx, left 0x%016llx\n",
+			err, (u64)features, (u64)dev->features);
 		return -1;
 	}
=20
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index af35d90..b7feeab 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -27,6 +27,7 @@
 #ifdef CONFIG_SYSFS
 static const char fmt_hex[] =3D "%#x\n";
 static const char fmt_long_hex[] =3D "%#lx\n";
+static const char fmt_long_long_hex[] =3D "%#llx\n";
 static const char fmt_dec[] =3D "%d\n";
 static const char fmt_udec[] =3D "%u\n";
 static const char fmt_ulong[] =3D "%lu\n";
@@ -100,7 +101,7 @@ NETDEVICE_SHOW(addr_assign_type, fmt_dec);
 NETDEVICE_SHOW(addr_len, fmt_dec);
 NETDEVICE_SHOW(iflink, fmt_dec);
 NETDEVICE_SHOW(ifindex, fmt_dec);
-NETDEVICE_SHOW(features, fmt_hex);	/* XXX: need %Fx */
+NETDEVICE_SHOW(features, fmt_long_long_hex);	/* XXX: need %Fx */
 NETDEVICE_SHOW(type, fmt_dec);
 NETDEVICE_SHOW(link_mode, fmt_dec);
=20
--=20
1.7.2.5

