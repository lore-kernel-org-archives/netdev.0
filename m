From: Johan Hovold <johan@kernel.org>
Subject: [PATCH] net: ch9200: add missing USB-descriptor endianness conversions
Date: Fri, 12 May 2017 12:13:26 +0200
Message-ID: <20170512101326.2029-1-johan@kernel.org>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        Johan Hovold <johan@kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35553 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756827AbdELKNz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 06:13:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the missing endianness conversions to a debug statement printing
the USB device-descriptor idVendor and idProduct fields during probe.

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/usb/ch9200.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/ch9200.c b/drivers/net/usb/ch9200.c
index c4f1c363e24b..9df3c1ffff35 100644
--- a/drivers/net/usb/ch9200.c
+++ b/drivers/net/usb/ch9200.c
@@ -310,8 +310,8 @@ static int get_mac_address(struct usbnet *dev, unsigned char *data)
 	int rd_mac_len = 0;
 
 	netdev_dbg(dev->net, "get_mac_address:\n\tusbnet VID:%0x PID:%0x\n",
-		   dev->udev->descriptor.idVendor,
-		   dev->udev->descriptor.idProduct);
+		   le16_to_cpu(dev->udev->descriptor.idVendor),
+		   le16_to_cpu(dev->udev->descriptor.idProduct));
 
 	memset(mac_addr, 0, sizeof(mac_addr));
 	rd_mac_len = control_read(dev, REQUEST_READ, 0,
-- 
2.13.0
