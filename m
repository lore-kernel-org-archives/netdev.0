From: <Woojung.Huh@microchip.com>
Subject: [PATCH net-next 1/2] lan78xx: change phy id and fix phy reset issue
Date: Fri, 21 Aug 2015 21:39:36 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D5480C7@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp02.microchip.com ([198.175.253.38]:35937 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752246AbbHUVji convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 17:39:38 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch to change internal PHYID to 1 and fix PHY reset issue.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/lan78xx.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 39364a4..4bcbf28 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -36,7 +36,7 @@
 #define DRIVER_AUTHOR	"WOOJUNG HUH <woojung.huh@microchip.com>"
 #define DRIVER_DESC	"LAN78XX USB 3.0 Gigabit Ethernet Devices"
 #define DRIVER_NAME	"lan78xx"
-#define DRIVER_VERSION	"1.0.0"
+#define DRIVER_VERSION	"1.0.1"
 
 #define TX_TIMEOUT_JIFFIES		(5 * HZ)
 #define THROTTLE_JIFFIES		(HZ / 8)
@@ -57,7 +57,7 @@
 #define DEFAULT_RX_CSUM_ENABLE		(true)
 #define DEFAULT_TSO_CSUM_ENABLE		(true)
 #define DEFAULT_VLAN_FILTER_ENABLE	(true)
-#define INTERNAL_PHY_ID			(2)	/* 2: GMII */
+#define INTERNAL_PHY_ID			(1)
 #define TX_OVERHEAD			(8)
 #define RXW_PADDING			2
 
@@ -2003,7 +2003,7 @@ static int lan78xx_reset(struct lan78xx_net *dev)
 			netdev_warn(dev->net, "timeout waiting for PHY Reset");
 			return -EIO;
 		}
-	} while (buf & PMT_CTL_PHY_RST_);
+	} while ((buf & PMT_CTL_PHY_RST_) || !(buf & PMT_CTL_READY_));
 
 	lan78xx_mii_init(dev);
 
-- 
2.1.4
