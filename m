From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 1/1] usbnet: allow type check of devdbg arguments in non-debug build
Date: Mon, 15 Sep 2008 16:47:44 +0100
Message-ID: <1221493664-544-1-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	Jeff Garzik <jeff@garzik.org>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.113] ([86.54.240.113]:43888 "EHLO drevil.shawell.net"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753722AbYIOPrv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2008 11:47:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

improve usbnet's devdbg to always type-check diagnostic arguments,
like dev_dbg (device.h).  This makes no change to the resulting size of
usbnet modules.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 include/linux/usb/usbnet.h |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index ba09fe8..7d38222 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -197,7 +197,9 @@ extern int usbnet_nway_reset(struct net_device *net);
 #define devdbg(usbnet, fmt, arg...) \
 	printk(KERN_DEBUG "%s: " fmt "\n" , (usbnet)->net->name , ## arg)
 #else
-#define devdbg(usbnet, fmt, arg...) do {} while(0)
+#define devdbg(usbnet, fmt, arg...) \
+	({ if (0) printk(KERN_DEBUG "%s: " fmt "\n" , (usbnet)->net->name , \
+		## arg); 0; })
 #endif
 
 #define deverr(usbnet, fmt, arg...) \
-- 
1.5.5.1

