From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 04/14] net/fec: no need to check for validity of ndev in suspend and resume
Date: Fri, 11 Feb 2011 11:32:12 +0100
Message-ID: <1297420342-17739-4-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@freescale.com>, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52461 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754291Ab1BKKcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 05:32:31 -0500
In-Reply-To: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_set_drvdata is called unconditionally in the probe function and so
it cannot be NULL.

Noticed-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/fec.c |   28 ++++++++++++----------------
 1 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index aa1db8e..8026a16 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1492,16 +1492,14 @@ static int
 fec_suspend(struct device *dev)
 {
 	struct net_device *ndev =3D dev_get_drvdata(dev);
-	struct fec_enet_private *fep;
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
=20
-	if (ndev) {
-		fep =3D netdev_priv(ndev);
-		if (netif_running(ndev)) {
-			fec_stop(ndev);
-			netif_device_detach(ndev);
-		}
-		clk_disable(fep->clk);
+	if (netif_running(ndev)) {
+		fec_stop(ndev);
+		netif_device_detach(ndev);
 	}
+	clk_disable(fep->clk);
+
 	return 0;
 }
=20
@@ -1509,16 +1507,14 @@ static int
 fec_resume(struct device *dev)
 {
 	struct net_device *ndev =3D dev_get_drvdata(dev);
-	struct fec_enet_private *fep;
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
=20
-	if (ndev) {
-		fep =3D netdev_priv(ndev);
-		clk_enable(fep->clk);
-		if (netif_running(ndev)) {
-			fec_restart(ndev, fep->full_duplex);
-			netif_device_attach(ndev);
-		}
+	clk_enable(fep->clk);
+	if (netif_running(ndev)) {
+		fec_restart(ndev, fep->full_duplex);
+		netif_device_attach(ndev);
 	}
+
 	return 0;
 }
=20
--=20
1.7.2.3

