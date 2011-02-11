From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 03/14] net/fec: don't free an irq that failed to be requested
Date: Fri, 11 Feb 2011 11:32:11 +0100
Message-ID: <1297420342-17739-3-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@freescale.com>, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52472 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755698Ab1BKKcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 05:32:35 -0500
In-Reply-To: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noticed-by: Lothar Wa=C3=9Fmann <LW@KARO-elektronics.de>
Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/fec.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index b079826..aa1db8e 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1409,10 +1409,9 @@ fec_probe(struct platform_device *pdev)
 			break;
 		ret =3D request_irq(irq, fec_enet_interrupt, IRQF_DISABLED, pdev->na=
me, ndev);
 		if (ret) {
-			while (i >=3D 0) {
+			while (--i >=3D 0) {
 				irq =3D platform_get_irq(pdev, i);
 				free_irq(irq, ndev);
-				i--;
 			}
 			goto failed_irq;
 		}
--=20
1.7.2.3

