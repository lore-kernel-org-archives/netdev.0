From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] net: phy: at803x: simplify using devm_gpiod_get_optional and its 4th argument
Date: Fri, 27 Mar 2015 20:25:02 +0100
Message-ID: <1427484302-17075-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Linus Walleij <linus.walleij@linaro.org>,
	Alexandre Courbot <acourbot@nvidia.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:51226 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbbC0TZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 15:25:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 39b2bbe3d715 (gpio: add flags argument to gpiod_get*() functions)
which appeared in v3.17-rc1, the gpiod_get* functions take an additiona=
l
parameter that allows to specify direction and initial value for output=
=2E
Moreover use devm_gpiod_get_index_optional instead of ignoring all
errors returned by devm_gpiod_get. Simplify accordingly.

The result is more strict error handling which is good.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/phy/at803x.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index f80e19ac6704..87dd633a8d1f 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -197,15 +197,12 @@ static int at803x_probe(struct phy_device *phydev=
)
 	if (!priv)
 		return -ENOMEM;
=20
-	priv->gpiod_reset =3D devm_gpiod_get(dev, "reset");
-	if (IS_ERR(priv->gpiod_reset))
-		priv->gpiod_reset =3D NULL;
-	else
-		gpiod_direction_output(priv->gpiod_reset, 1);
+	priv->gpiod_reset =3D devm_gpiod_get_optional(dev, "reset",
+						    GPIOD_OUT_HIGH);
=20
 	phydev->priv =3D priv;
=20
-	return 0;
+	return IS_ERR(priv->gpiod_reset);
 }
=20
 static int at803x_config_init(struct phy_device *phydev)
--=20
2.1.4
