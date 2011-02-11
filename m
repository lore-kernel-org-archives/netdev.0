From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 06/14] net/fec: put the ioremap cookie immediately into a void __iomem pointer
Date: Fri, 11 Feb 2011 11:32:14 +0100
Message-ID: <1297420342-17739-6-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@freescale.com>, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:45127 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755957Ab1BKKco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 05:32:44 -0500
In-Reply-To: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Saving it first into struct net_device->base_addr (which is an unsigned
long) is pointless and only needs to use more casts than necessary.

Noticed-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/fec.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 9a25e1e..14eb660 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1170,7 +1170,6 @@ static int fec_enet_init(struct net_device *dev)
=20
 	spin_lock_init(&fep->hw_lock);
=20
-	fep->hwp =3D (void __iomem *)dev->base_addr;
 	fep->netdev =3D dev;
=20
 	/* Get the Ethernet address */
@@ -1387,10 +1386,10 @@ fec_probe(struct platform_device *pdev)
 	/* setup board info structure */
 	fep =3D netdev_priv(ndev);
=20
-	ndev->base_addr =3D (unsigned long)ioremap(r->start, resource_size(r)=
);
+	fep->hwp =3D ioremap(r->start, resource_size(r));
 	fep->pdev =3D pdev;
=20
-	if (!ndev->base_addr) {
+	if (!fep->hwp) {
 		ret =3D -ENOMEM;
 		goto failed_ioremap;
 	}
@@ -1453,7 +1452,7 @@ failed_clk:
 			free_irq(irq, ndev);
 	}
 failed_irq:
-	iounmap((void __iomem *)ndev->base_addr);
+	iounmap(fep->hwp);
 failed_ioremap:
 	free_netdev(ndev);
 failed_alloc_etherdev:
@@ -1475,7 +1474,7 @@ fec_drv_remove(struct platform_device *pdev)
 	fec_enet_mii_remove(fep);
 	clk_disable(fep->clk);
 	clk_put(fep->clk);
-	iounmap((void __iomem *)ndev->base_addr);
+	iounmap(fep->hwp);
 	unregister_netdev(ndev);
 	free_netdev(ndev);
=20
--=20
1.7.2.3

