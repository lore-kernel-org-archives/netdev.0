From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] phylib: unsigneds go unnoticed
Date: Mon, 19 Jan 2009 10:41:58 +0100
Message-ID: <49744AE6.9@gmail.com>
References: <4973B3E7.6080203@gmail.com> <20090118.212512.149560148.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: paulius.zaleckas@teltonika.lt, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f31.google.com ([209.85.219.31]:60864 "EHLO
	mail-ew0-f31.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757014AbZASJmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 04:42:02 -0500
Received: by ewy12 with SMTP id 12so978263ewy.13
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2009 01:42:00 -0800 (PST)
In-Reply-To: <20090118.212512.149560148.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Roel Kluin <roel.kluin@gmail.com>
> Date: Sun, 18 Jan 2009 23:57:43 +0100
> 
>> both pdata->mdc and pdata->mdio are unsigned. Notice a negative
>> return value.
> 
> You left the unsigned tests in there:
> 
>>  	if (pdata->mdc < 0 || pdata->mdio < 0)
>>  		goto out_free;
> 
> Please remove them.

thanks, here it is, also with a signoff:

both pdata->mdc and pdata->mdio are unsigned. Notice a negative
return value.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index a439ebe..3f460c5 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -200,16 +200,21 @@ static int __devinit mdio_ofgpio_probe(struct of_device *ofdev,
 {
 	struct device_node *np = NULL;
 	struct mdio_gpio_platform_data *pdata;
+	int ret;
 
 	pdata = kzalloc(sizeof(*pdata), GFP_KERNEL);
 	if (!pdata)
 		return -ENOMEM;
 
-	pdata->mdc = of_get_gpio(ofdev->node, 0);
-	pdata->mdio = of_get_gpio(ofdev->node, 1);
-
-	if (pdata->mdc < 0 || pdata->mdio < 0)
+	ret = of_get_gpio(ofdev->node, 0);
+	if (ret < 0)
 		goto out_free;
+	pdata->mdc = ret;
+
+	ret = of_get_gpio(ofdev->node, 1);
+	if (ret < 0)
+                goto out_free;
+	pdata->mdio = ret;
 
 	while ((np = of_get_next_child(ofdev->node, np)))
 		if (!strcmp(np->type, "ethernet-phy"))
