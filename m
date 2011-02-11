From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 13/14] net/fec: postpone unsetting driver data until the hardware is stopped
Date: Fri, 11 Feb 2011 11:32:21 +0100
Message-ID: <1297420342-17739-13-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@freescale.com>, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:45169 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756069Ab1BKKdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 05:33:04 -0500
In-Reply-To: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noticed-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/fec.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 0c984d6..c322971 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1465,8 +1465,6 @@ fec_drv_remove(struct platform_device *pdev)
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
 	struct resource *r;
=20
-	platform_set_drvdata(pdev, NULL);
-
 	fec_stop(ndev);
 	fec_enet_mii_remove(fep);
 	clk_disable(fep->clk);
@@ -1479,6 +1477,8 @@ fec_drv_remove(struct platform_device *pdev)
 	BUG_ON(!r);
 	release_mem_region(r->start, resource_size(r));
=20
+	platform_set_drvdata(pdev, NULL);
+
 	return 0;
 }
=20
--=20
1.7.2.3

