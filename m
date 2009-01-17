From: David Brownell <david-b@pacbell.net>
Subject: [patch 2.6.29-rc] usbnet: allow type check of devdbg arguments in non-debug build
Date: Fri, 16 Jan 2009 23:19:44 -0800
Message-ID: <200901162319.44255.david-b@pacbell.net>
References: <1221493664-544-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Steve Glendinning <steve.glendinning@smsc.com>,
	Ian Saturley <ian.saturley@smsc.com>,
	Jeff Garzik <jeff@garzik.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp128.sbc.mail.sp1.yahoo.com ([69.147.65.187]:27218 "HELO
	smtp128.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750903AbZAQHTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2009 02:19:51 -0500
In-Reply-To: <1221493664-544-1-git-send-email-steve.glendinning@smsc.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: usbnet: allow type check of devdbg arguments in non-debug build

Improve usbnet's devdbg to always type-check diagnostic arguments,
like dev_dbg (device.h).  This makes no change to the resulting size of
usbnet modules.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
---
[ refreshed against 2.6.29-rc1 GIT ]

 include/linux/usb/usbnet.h |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -197,7 +197,9 @@ extern int usbnet_nway_reset(struct net_
 #define devdbg(usbnet, fmt, arg...) \
 	printk(KERN_DEBUG "%s: " fmt "\n" , (usbnet)->net->name , ## arg)
 #else
-#define devdbg(usbnet, fmt, arg...) do {} while(0)
+#define devdbg(usbnet, fmt, arg...) \
+	({ if (0) printk(KERN_DEBUG "%s: " fmt "\n" , (usbnet)->net->name , \
+		## arg); 0; })
 #endif
 
 #define deverr(usbnet, fmt, arg...) \
