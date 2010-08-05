From: Christian Samsel <christian.samsel@rwth-aachen.de>
Subject: [PATCH] usbnet: remove noisy and hardly useful printk
Date: Thu, 05 Aug 2010 10:14:36 +0200
Message-ID: <1280996076-19708-1-git-send-email-christian.samsel@rwth-aachen.de>
Content-Transfer-Encoding: 7BIT
Cc: dhollis@davehollis.com,
	Christian Samsel <christian.samsel@rwth-aachen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:56777 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759845Ab0HEIOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 04:14:47 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0L6O00F1J6WMBNA0@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Thu, 05 Aug 2010 10:14:46 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With turned on hspa modem (Dell 5530 internal card) and activated usb auto
suspend, my system gets up 100 "usbnet_resume has delayed data" per
minute. I didnt noticed any pathological behaviour, so just drop
this message. if any objections, please at least change it to _DEBUG.

Signed-off-by: Christian Samsel <christian.samsel@rwth-aachen.de>
---
 drivers/net/usb/usbnet.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 3b03794..7f62e2d 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1457,7 +1457,6 @@ int usbnet_resume (struct usb_interface *intf)
 		spin_lock_irq(&dev->txq.lock);
 		while ((res = usb_get_from_anchor(&dev->deferred))) {
 
-			printk(KERN_INFO"%s has delayed data\n", __func__);
 			skb = (struct sk_buff *)res->context;
 			retval = usb_submit_urb(res, GFP_ATOMIC);
 			if (retval < 0) {
-- 
1.7.2

