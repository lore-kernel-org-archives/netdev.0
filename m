From: =?utf-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] move jazzsonic's probe function to .devinit.text
Date: Tue, 21 Jul 2009 23:25:22 +0200
Message-ID: <1248211527-32253-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jeff@garzik.org>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	Finn Thain <fthain@telegraphics.com.au>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:53218 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754035AbZGUVZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 17:25:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A pointer to jazz_sonic_probe is passed to the core via
platform_driver_register and so the function must not disappear when th=
e
=2Einit sections are discarded.  Otherwise (if also having HOTPLUG=3Dy)
unbinding and binding a device to the driver via sysfs will result in a=
n
oops as does a device being registered late.

As noticed by Geert Uytterhoeven sonic_probe1 is called by
jazz_sonic_probe, so the former has to move to .devinit.text, too.

An alternative to this patch is using platform_driver_probe instead of
platform_driver_register plus removing the pointer to the probe functio=
n
from the struct platform_driver.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
Acked-by: Ralf Baechle <ralf@linux-mips.org>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Cc: Finn Thain <fthain@telegraphics.com.au>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/net/jazzsonic.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/jazzsonic.c b/drivers/net/jazzsonic.c
index d12106b..8baf595 100644
--- a/drivers/net/jazzsonic.c
+++ b/drivers/net/jazzsonic.c
@@ -108,7 +108,7 @@ static const struct net_device_ops sonic_netdev_ops=
 =3D {
 	.ndo_set_mac_address	=3D eth_mac_addr,
 };
=20
-static int __init sonic_probe1(struct net_device *dev)
+static int __devinit sonic_probe1(struct net_device *dev)
 {
 	static unsigned version_printed;
 	unsigned int silicon_revision;
@@ -211,7 +211,7 @@ out:
  * Probe for a SONIC ethernet controller on a Mips Jazz board.
  * Actually probing is superfluous but we're paranoid.
  */
-static int __init jazz_sonic_probe(struct platform_device *pdev)
+static int __devinit jazz_sonic_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct sonic_local *lp;
--=20
tg: (aea1f79..) t/platsection/jazz_sonic_driver (depends on: linus/mast=
er)
