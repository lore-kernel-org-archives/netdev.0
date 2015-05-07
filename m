From: Ruslan Bilovol <ruslan.bilovol@gmail.com>
Subject: [PATCH] net: usb: allow MTU that is a multiple of USB packet size
Date: Thu,  7 May 2015 12:49:18 +0300
Message-ID: <1430992159-27783-1-git-send-email-ruslan.bilovol@gmail.com>
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: oneukum@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:36569 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752770AbbEGJtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 05:49:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current usbnet driver rejects setting MTU that is a multiple
of USB endpoint's wMaxPacketSize size. However, it may only
lead to possible performance degradation but is not so
critical that its using should be prohibited. So allow it
but also warn user about possible issue.

Signed-off-by: Ruslan Bilovol <ruslan.bilovol@gmail.com>
---
 drivers/net/usb/usbnet.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 733f4fe..09dc848 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -382,9 +382,11 @@ int usbnet_change_mtu (struct net_device *net, int new_mtu)
 
 	if (new_mtu <= 0)
 		return -EINVAL;
-	// no second zero-length packet read wanted after mtu-sized packets
+	/* warn about second zero-length packet read after mtu-sized packets */
 	if ((ll_mtu % dev->maxpacket) == 0)
-		return -EDOM;
+		netdev_warn(dev->net, "MTU %d is a multiple of USB wMaxPacketSize (%d),"
+				" consider possible performance degradation\n",
+				ll_mtu, dev->maxpacket);
 	net->mtu = new_mtu;
 
 	dev->hard_mtu = net->mtu + net->hard_header_len;
-- 
1.7.9.5
