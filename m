From: =?utf-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] move meth's probe function to .devinit.text
Date: Tue, 21 Jul 2009 23:25:24 +0200
Message-ID: <1248211527-32253-3-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1248211527-32253-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	Christoph Lameter <cl@linux-foundation.org>,
	Jeff Garzik <jgarzik@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:53213 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754461AbZGUVZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 17:25:41 -0400
In-Reply-To: <1248211527-32253-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A pointer to meth_probe is passed to the core via
platform_driver_register and so the function must not disappear when th=
e
=2Einit sections are discarded.  Otherwise (if also having HOTPLUG=3Dy)
unbinding and binding a device to the driver via sysfs will result in a=
n
oops as does a device being registered late.

An alternative to this patch is using platform_driver_probe instead of
platform_driver_register plus removing the pointer to the probe functio=
n
from the struct platform_driver.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
Cc: David S. Miller <davem@davemloft.net>
Cc: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Jeff Garzik <jgarzik@redhat.com>
Acked-by: Ralf Baechle <ralf@linux-mips.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/net/meth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/meth.c b/drivers/net/meth.c
index 5d04d94..0dddb02 100644
--- a/drivers/net/meth.c
+++ b/drivers/net/meth.c
@@ -784,7 +784,7 @@ static const struct net_device_ops meth_netdev_ops =
=3D {
 /*
  * The init function.
  */
-static int __init meth_probe(struct platform_device *pdev)
+static int __devinit meth_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct meth_private *priv;
--=20
tg: (aea1f79..) t/platsection/meth_driver (depends on: linus/master)
