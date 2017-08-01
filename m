From: <Nisar.Sayed@microchip.com>
Subject: [PATCH net 2/2] lan78xx: Fix to handle hard_header_len update
Date: Tue, 1 Aug 2017 10:24:33 +0000
Message-ID: <CE371C1263339941885964188A0225FA322BE5@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <UNGLinuxDriver@microchip.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa6.microchip.iphmx.com ([216.71.154.253]:42402 "EHLO
        esa6.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751808AbdHAKYq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 06:24:46 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nisar Sayed <Nisar.Sayed@microchip.com>

Fix to handle hard_header_len update

When ifconfig up/down sequence is initiated hard_header_len
get updated incrementally for each ifconfig up /down sequence,
this leads invalid hard_header_len, moving to lan78xx_bind
to have one time update of hard_header_len addresses the issue.

Signed-off-by: Nisar Sayed <Nisar.Sayed@microchip.com>
---
 drivers/net/usb/lan78xx.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 8ef3639..b99a7fb 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -2367,9 +2367,6 @@ static int lan78xx_reset(struct lan78xx_net *dev)
 	/* Init LTM */
 	lan78xx_init_ltm(dev);
 
-	dev->net->hard_header_len += TX_OVERHEAD;
-	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
-
 	if (dev->udev->speed == USB_SPEED_SUPER) {
 		buf = DEFAULT_BURST_CAP_SIZE / SS_USB_PKT_SIZE;
 		dev->rx_urb_size = DEFAULT_BURST_CAP_SIZE;
@@ -2855,6 +2852,9 @@ static int lan78xx_bind(struct lan78xx_net *dev, struct usb_interface *intf)
 		return ret;
 	}
 
+	dev->net->hard_header_len += TX_OVERHEAD;
+	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
+
 	/* Init all registers */
 	ret = lan78xx_reset(dev);
 
-- 
1.9.1
