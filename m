From: =?utf-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] move sgiseeq's probe function to .devinit.text
Date: Tue, 21 Jul 2009 23:25:26 +0200
Message-ID: <1248211527-32253-5-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1248211527-32253-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wang Chen <wangchen@cn.fujitsu.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@redhat.com>,
	Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:53240 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755503AbZGUVZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 17:25:48 -0400
In-Reply-To: <1248211527-32253-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A pointer to sgiseeq_probe is passed to the core via
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
Cc: Wang Chen <wangchen@cn.fujitsu.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Jeff Garzik <jgarzik@redhat.com>
Cc: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Acked-by: Ralf Baechle <ralf@linux-mips.org>
Cc: Greg Kroah-Hartman <gregkh@suse.de>
Cc: netdev@vger.kernel.org

---
 drivers/net/sgiseeq.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index 5fb88ca..53fa4f6 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -720,7 +720,7 @@ static const struct net_device_ops sgiseeq_netdev_o=
ps =3D {
 	.ndo_validate_addr	=3D eth_validate_addr,
 };
=20
-static int __init sgiseeq_probe(struct platform_device *pdev)
+static int __devinit sgiseeq_probe(struct platform_device *pdev)
 {
 	struct sgiseeq_platform_data *pd =3D pdev->dev.platform_data;
 	struct hpc3_regs *hpcregs =3D pd->hpc;
--=20
tg: (aea1f79..) t/platsection/sgiseeq_driver (depends on: linus/master)
