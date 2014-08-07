From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] net: gianfar: no need to check parameter being != NULL for of_node_put
Date: Thu,  7 Aug 2014 21:20:12 +0200
Message-ID: <1407439212-16661-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>,
	kernel@pengutronix.de, Florian Fainelli <f.fainelli@gmail.com>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: netdev@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:50342 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755318AbaHGTUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 15:20:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_node_put is a noop when being called with NULL.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
Hello,

@Julia: I'm sure it's easy to create a coccinelle rule for this.

Best regards
Uwe

 drivers/net/ethernet/freescale/gianfar.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/eth=
ernet/freescale/gianfar.c
index a6cf40e62f3a..6b0c4775cd0d 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1435,10 +1435,8 @@ register_fail:
 	unmap_group_regs(priv);
 	gfar_free_rx_queues(priv);
 	gfar_free_tx_queues(priv);
-	if (priv->phy_node)
-		of_node_put(priv->phy_node);
-	if (priv->tbi_node)
-		of_node_put(priv->tbi_node);
+	of_node_put(priv->phy_node);
+	of_node_put(priv->tbi_node);
 	free_gfar_dev(priv);
 	return err;
 }
@@ -1447,10 +1445,8 @@ static int gfar_remove(struct platform_device *o=
fdev)
 {
 	struct gfar_private *priv =3D platform_get_drvdata(ofdev);
=20
-	if (priv->phy_node)
-		of_node_put(priv->phy_node);
-	if (priv->tbi_node)
-		of_node_put(priv->tbi_node);
+	of_node_put(priv->phy_node);
+	of_node_put(priv->tbi_node);
=20
 	unregister_netdev(priv->ndev);
 	unmap_group_regs(priv);
--=20
2.0.1
