From: Maris Paupe <marisp@mt.lv>
Subject: [PATCH]  fix sierra_net endianess bug
Date: Wed, 14 Mar 2012 16:09:25 +0200
Message-ID: <4F60A695.4040601@mt.lv>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: epasheva@sierrawireless.com, rfiler@sierrawireless.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bute.mt.lv ([159.148.172.195]:37741 "EHLO bute.mt.lv"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030697Ab2CNO2O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Mar 2012 10:28:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
I have found that sierra_net does not work properly on big-endian
systems, it works if bytes are flipped in this particular location.

Signed-off-by: Maris Paupe <marisp@mt.lv>
---
diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.c
index b59cf20..cf11924 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -779,7 +779,7 @@ static int sierra_net_bind(struct usbnet *dev, struct usb_interface *intf)
  	dev_dbg(&dev->udev->dev, "Fw attr: %x\n", fwattr);
  
  	/* test whether firmware supports DHCP */
-	if (!(status == sizeof(fwattr) && (fwattr & SWI_GET_FW_ATTR_MASK))) {
+	if (!(status == sizeof(fwattr) && (le16_to_cpu(fwattr) & SWI_GET_FW_ATTR_MASK))) {
  		/* found incompatible firmware version */
  		dev_err(&dev->udev->dev, "Incompatible driver and firmware"
  			" versions\n");
---
