From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 30/31] net: mdio-gpio: use dev_get_platdata()
Date: Fri, 30 Aug 2013 14:08:55 +0900
Message-ID: <004e01cea53f$069f29e0$13dd7da0$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:11664 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752764Ab3H3FI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 01:08:57 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB002QMVJAOIP0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 14:08:54 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/phy/mdio-gpio.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index a47f923..8004acb 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -191,7 +191,7 @@ static int mdio_gpio_probe(struct platform_device *pdev)
 		pdata = mdio_gpio_of_get_data(pdev);
 		bus_id = of_alias_get_id(pdev->dev.of_node, "mdio-gpio");
 	} else {
-		pdata = pdev->dev.platform_data;
+		pdata = dev_get_platdata(&pdev->dev);
 		bus_id = pdev->id;
 	}
 
-- 
1.7.10.4
