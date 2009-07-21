From: =?utf-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] move macsonic's probe function to .devinit.text
Date: Tue, 21 Jul 2009 23:25:23 +0200
Message-ID: <1248211527-32253-2-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1248211527-32253-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:53211 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754035AbZGUVZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 17:25:39 -0400
In-Reply-To: <1248211527-32253-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A pointer to mac_sonic_probe is passed to the core via
platform_driver_register and so the function must not disappear when th=
e
=2Einit sections are discarded.  Otherwise (if also having HOTPLUG=3Dy)
unbinding and binding a device to the driver via sysfs will result in a=
n
oops as does a device being registered late.

Various other functions that are called by mac_sonic_probe need to move
to .devinit.text, too.

An alternative to this patch is using platform_driver_probe instead of
platform_driver_register plus removing the pointer to the probe functio=
n
from the struct platform_driver.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
Cc: Jeff Garzik <jgarzik@redhat.com>
Cc: David S. Miller <davem@davemloft.net>
Tested-by: Finn Thain <fthain@telegraphics.com.au>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/net/macsonic.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/macsonic.c b/drivers/net/macsonic.c
index acd143d..8f492c7 100644
--- a/drivers/net/macsonic.c
+++ b/drivers/net/macsonic.c
@@ -179,7 +179,7 @@ static const struct net_device_ops macsonic_netdev_=
ops =3D {
 	.ndo_set_mac_address	=3D eth_mac_addr,
 };
=20
-static int __init macsonic_init(struct net_device *dev)
+static int __devinit macsonic_init(struct net_device *dev)
 {
 	struct sonic_local* lp =3D netdev_priv(dev);
=20
@@ -223,7 +223,7 @@ static int __init macsonic_init(struct net_device *=
dev)
 	return 0;
 }
=20
-static int __init mac_onboard_sonic_ethernet_addr(struct net_device *d=
ev)
+static int __devinit mac_onboard_sonic_ethernet_addr(struct net_device=
 *dev)
 {
 	struct sonic_local *lp =3D netdev_priv(dev);
 	const int prom_addr =3D ONBOARD_SONIC_PROM_BASE;
@@ -288,7 +288,7 @@ static int __init mac_onboard_sonic_ethernet_addr(s=
truct net_device *dev)
 	} else return 0;
 }
=20
-static int __init mac_onboard_sonic_probe(struct net_device *dev)
+static int __devinit mac_onboard_sonic_probe(struct net_device *dev)
 {
 	/* Bwahahaha */
 	static int once_is_more_than_enough;
@@ -409,7 +409,7 @@ static int __init mac_onboard_sonic_probe(struct ne=
t_device *dev)
 	return macsonic_init(dev);
 }
=20
-static int __init mac_nubus_sonic_ethernet_addr(struct net_device *dev=
,
+static int __devinit mac_nubus_sonic_ethernet_addr(struct net_device *=
dev,
 						unsigned long prom_addr,
 						int id)
 {
@@ -424,7 +424,7 @@ static int __init mac_nubus_sonic_ethernet_addr(str=
uct net_device *dev,
 	return 0;
 }
=20
-static int __init macsonic_ident(struct nubus_dev *ndev)
+static int __devinit macsonic_ident(struct nubus_dev *ndev)
 {
 	if (ndev->dr_hw =3D=3D NUBUS_DRHW_ASANTE_LC &&
 	    ndev->dr_sw =3D=3D NUBUS_DRSW_SONIC_LC)
@@ -449,7 +449,7 @@ static int __init macsonic_ident(struct nubus_dev *=
ndev)
 	return -1;
 }
=20
-static int __init mac_nubus_sonic_probe(struct net_device *dev)
+static int __devinit mac_nubus_sonic_probe(struct net_device *dev)
 {
 	static int slots;
 	struct nubus_dev* ndev =3D NULL;
@@ -562,7 +562,7 @@ static int __init mac_nubus_sonic_probe(struct net_=
device *dev)
 	return macsonic_init(dev);
 }
=20
-static int __init mac_sonic_probe(struct platform_device *pdev)
+static int __devinit mac_sonic_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct sonic_local *lp;
--=20
tg: (aea1f79..) t/platsection/mac_sonic_driver (depends on: linus/maste=
r)
