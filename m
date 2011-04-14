From: huajun li <huajun.li.lee@gmail.com>
Subject: [PATCH] Clean up 'FLAG_POINTTOPOINT' and 'FLAG_MULTI_PACKET' overlaps
 in usbnet.h
Date: Thu, 14 Apr 2011 09:43:32 +0800
Message-ID: <BANLkTinyWLjVRLKTZB09BZaH2o0gB0p8JA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Gottfried Haider <gottfried.haider@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38579 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754433Ab1DNBnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 21:43:33 -0400
Received: by fxm17 with SMTP id 17so864127fxm.19
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2011 18:43:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

USB tethering does not work anymore since 2.6.39-rc2, but it's okay in
-rc1. The root cause is the new added mask code 'FLAG_POINTTOPOINT'
overlaps 'FLAG_MULTI_PACKET'  in  include/linux/usb/usbnet.h, this
causes logic issue in  rx_process(). This patch cleans up the overlap.


Reported-and-Tested-by: Gottfried Haider <gottfried.haider@gmail.com>
Signed-off-by:  Huajun Li <huajun.li.lee@gmail.com>
---
 include/linux/usb/usbnet.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 3c7329b..0e18550 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -103,8 +103,8 @@ struct driver_info {
  * Indicates to usbnet, that USB driver accumulates multiple IP packets.
  * Affects statistic (counters) and short packet handling.
  */
-#define FLAG_MULTI_PACKET	0x1000
-#define FLAG_RX_ASSEMBLE	0x2000	/* rx packets may span >1 frames */
+#define FLAG_MULTI_PACKET	0x2000
+#define FLAG_RX_ASSEMBLE	0x4000	/* rx packets may span >1 frames */

 	/* init device ... can sleep, or cause probe() failure */
 	int	(*bind)(struct usbnet *, struct usb_interface *);
-- 
1.7.4.1
