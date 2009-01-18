From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] phylib: unsigneds go unnoticed
Date: Sun, 18 Jan 2009 23:57:43 +0100
Message-ID: <4973B3E7.6080203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paulius.zaleckas@teltonika.lt,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:28202 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753039AbZARXEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 18:04:10 -0500
Received: by nf-out-0910.google.com with SMTP id d3so378177nfc.21
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2009 15:04:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

both pdata->mdc and pdata->mdio are unsigned. Notice a negative
return value.

diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index a439ebe..9b1dcd6 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -200,13 +200,21 @@ static int __devinit mdio_ofgpio_probe(struct of_device *ofdev,
 {
 	struct device_node *np = NULL;
 	struct mdio_gpio_platform_data *pdata;
+	int ret;
 
 	pdata = kzalloc(sizeof(*pdata), GFP_KERNEL);
 	if (!pdata)
 		return -ENOMEM;
 
-	pdata->mdc = of_get_gpio(ofdev->node, 0);
-	pdata->mdio = of_get_gpio(ofdev->node, 1);
+	ret = of_get_gpio(ofdev->node, 0);
+	if (ret < 0)
+		goto out_free;
+	pdata->mdc = ret;
+
+	ret = of_get_gpio(ofdev->node, 1);
+	if (ret < 0)
+                goto out_free;
+	pdata->mdio = ret;
 
 	if (pdata->mdc < 0 || pdata->mdio < 0)
 		goto out_free;
