From: Sebastian Frias <sf84@laposte.net>
Subject: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Wed, 16 Mar 2016 18:25:59 +0100
Message-ID: <56E99727.9040702@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>
To: =?UTF-8?B?VXdlIEtsZWluZS1Lw7ZuaWc=?=
	<u.kleine-koenig@pengutronix.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpoutz28.laposte.net ([194.117.213.103]:52394 "EHLO
	smtp.laposte.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933085AbcCPRuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 13:50:32 -0400
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout016 (Postfix) with ESMTP id 39337110D48
	for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 18:26:00 +0100 (CET)
Received: from lpn-prd-vrin004 (lpn-prd-vrin004.laposte [10.128.63.5])
	by lpn-prd-vrout016 (Postfix) with ESMTP id 360E4110D1B
	for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 18:26:00 +0100 (CET)
Received: from lpn-prd-vrin004 (localhost [127.0.0.1])
	by lpn-prd-vrin004 (Postfix) with ESMTP id 228E870E274
	for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 18:26:00 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 687908c2b649 ("net: phy: at803x: simplify using
devm_gpiod_get_optional and its 4th argument") introduced a dependency
on GPIOLIB that was not there before.

This commit removes such dependency by checking the return code and
comparing it against ENOSYS which is returned when GPIOLIB is not
selected.

Fixes: 687908c2b649 ("net: phy: at803x: simplify using
devm_gpiod_get_optional and its 4th argument")

Signed-off-by: Sebastian Frias <sf84@laposte.net>
---
 drivers/net/phy/at803x.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index 2174ec9..88b7ff3 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -252,7 +252,9 @@ static int at803x_probe(struct phy_device *phydev)
 		return -ENOMEM;

 	gpiod_reset = devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_HIGH);
-	if (IS_ERR(gpiod_reset))
+	if (PTR_ERR(gpiod_reset) == -ENOSYS)
+		gpiod_reset = NULL;
+	else if (IS_ERR(gpiod_reset))
 		return PTR_ERR(gpiod_reset);

 	priv->gpiod_reset = gpiod_reset;
-- 
2.1.4
