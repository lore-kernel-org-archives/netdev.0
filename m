From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] ethtool: ETHTOOL_SFEATURES: remove NETIF_F_COMPAT return
Date: Mon, 16 May 2011 15:28:07 +0200 (CEST)
Message-ID: <20110516132807.1A89F13A6A@rere.qmqm.pl>
References: <20110516121339.GA1094@rere.qmqm.pl>
	<1305335142.2851.70.camel@bwh-desktop>
	<20110514103539.GA5214@rere.qmqm.pl>
	<1305513923.19966.20.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:40927 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754035Ab1EPN2I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2011 09:28:08 -0400
In-Reply-To: <20110516121339.GA1094@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove NETIF_F_COMPAT since it's redundant and will be unused after
all drivers are converted to fix/set_features.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---

=46or net as we don't want to have ETHTOOL_F_COMPAT hit stable release.

 include/linux/ethtool.h |    5 -----
 net/core/ethtool.c      |    2 +-
 2 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index dc80d82..5fb916c 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -625,9 +625,6 @@ struct ethtool_sfeatures {
  *      Probably there are other device-specific constraints on some f=
eatures
  *      in the set. When %ETHTOOL_F_UNSUPPORTED is set, .valid is cons=
idered
  *      here as though ignored bits were cleared.
- *   %ETHTOOL_F_COMPAT - some or all changes requested were made by ca=
lling
- *      compatibility functions. Requested offload state cannot be pro=
perly
- *      managed by kernel.
  *
  * Meaning of bits in the masks are obtained by %ETHTOOL_GSSET_INFO (n=
umber of
  * bits in the arrays - always multiple of 32) and %ETHTOOL_GSTRINGS c=
ommands
@@ -637,12 +634,10 @@ struct ethtool_sfeatures {
 enum ethtool_sfeatures_retval_bits {
 	ETHTOOL_F_UNSUPPORTED__BIT,
 	ETHTOOL_F_WISH__BIT,
-	ETHTOOL_F_COMPAT__BIT,
 };
=20
 #define ETHTOOL_F_UNSUPPORTED   (1 << ETHTOOL_F_UNSUPPORTED__BIT)
 #define ETHTOOL_F_WISH          (1 << ETHTOOL_F_WISH__BIT)
-#define ETHTOOL_F_COMPAT        (1 << ETHTOOL_F_COMPAT__BIT)
=20
 #ifdef __KERNEL__
=20
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 74ead9e..dc07569 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -308,7 +308,7 @@ static int ethtool_set_features(struct net_device *=
dev, void __user *useraddr)
 		return -EINVAL;
=20
 	if (ethtool_set_features_compat(dev, features))
-		ret |=3D ETHTOOL_F_COMPAT;
+		ret |=3D ETHTOOL_F_WISH;
=20
 	if (features[0].valid & ~dev->hw_features) {
 		features[0].valid &=3D dev->hw_features;

