From: <Woojung.Huh@microchip.com>
Subject: [PATCH net 1/6] lan78xx: Check device ready bit (PMT_CTL_READY_)
 after reset the PHY
Date: Wed, 16 Sep 2015 23:40:39 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D55C688@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:47241 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752663AbbIPXkk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 19:40:40 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check device ready bit (PMT_CTL_READY_) after reset the PHY.
Device may not be ready even if PHY_RST_ is cleared depends on configuration.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/lan78xx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index a39518f..d0d8790 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -2002,7 +2002,7 @@ static int lan78xx_reset(struct lan78xx_net *dev)
 			netdev_warn(dev->net, "timeout waiting for PHY Reset");
 			return -EIO;
 		}
-	} while (buf & PMT_CTL_PHY_RST_);
+	} while ((buf & PMT_CTL_PHY_RST_) || !(buf & PMT_CTL_READY_));
 
 	lan78xx_mii_init(dev);
 
-- 
2.1.4
