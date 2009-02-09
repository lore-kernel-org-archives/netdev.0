From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] mdio-gpio: Add mdc pin direction initialization
Date: Mon, 09 Feb 2009 11:46:01 +0200
Message-ID: <20090209094600.8667.81904.stgit@Programuotojas>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-7-68-229.static.zebra.lt ([81.7.68.229]:40207 "EHLO
	teltonika.lt" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752395AbZBIJww (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2009 04:52:52 -0500
Received: from unknown (HELO [127.0.0.1]) (paulius.zaleckas@[217.147.39.138])
          (envelope-sender <paulius.zaleckas@teltonika.lt>)
          by teltonika.lt (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 9 Feb 2009 09:49:01 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mdc pin should always be output. Initialize it as output,
so each board code does not need to do this.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
---

 drivers/net/phy/mdio-gpio.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)


diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index a439ebe..af28ff7 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -125,6 +125,8 @@ static int __devinit mdio_gpio_bus_init(struct device *dev,
 	if (gpio_request(bitbang->mdio, "mdio"))
 		goto out_free_mdc;
 
+	gpio_direction_output(bitbang->mdc, 0);
+
 	dev_set_drvdata(dev, new_bus);
 
 	ret = mdiobus_register(new_bus);

