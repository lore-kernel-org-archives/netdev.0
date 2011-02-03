From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v4 5/5] loopback: convert to hw_features
Date: Thu,  3 Feb 2011 15:21:22 +0100 (CET)
Message-ID: <38aaa7ba1c3fa19ec27536ccdf44c7368d1b21ac.1296741562.git.mirq-linux@rere.qmqm.pl>
References: <cover.1296741561.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:34560 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932224Ab1BCOV0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Feb 2011 09:21:26 -0500
In-Reply-To: <cover.1296741561.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This also enables TSOv6, TSO-ECN, and UFO as loopback clearly can handl=
e them.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/loopback.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 2d9663a..97b116b 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -129,10 +129,6 @@ static u32 always_on(struct net_device *dev)
=20
 static const struct ethtool_ops loopback_ethtool_ops =3D {
 	.get_link		=3D always_on,
-	.set_tso		=3D ethtool_op_set_tso,
-	.get_tx_csum		=3D always_on,
-	.get_sg			=3D always_on,
-	.get_rx_csum		=3D always_on,
 };
=20
 static int loopback_dev_init(struct net_device *dev)
@@ -169,9 +165,12 @@ static void loopback_setup(struct net_device *dev)
 	dev->type		=3D ARPHRD_LOOPBACK;	/* 0x0001*/
 	dev->flags		=3D IFF_LOOPBACK;
 	dev->priv_flags	       &=3D ~IFF_XMIT_DST_RELEASE;
+	dev->hw_features	=3D NETIF_F_ALL_TSO;
 	dev->features 		=3D NETIF_F_SG | NETIF_F_FRAGLIST
-		| NETIF_F_TSO
+		| NETIF_F_ALL_TSO
+		| NETIF_F_UFO
 		| NETIF_F_NO_CSUM
+		| NETIF_F_RXCSUM
 		| NETIF_F_HIGHDMA
 		| NETIF_F_LLTX
 		| NETIF_F_NETNS_LOCAL;
--=20
1.7.2.3

