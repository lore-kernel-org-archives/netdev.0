From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 2/2] usbnet: allow type check of devdbg arguments in non-debug build
Date: Tue, 20 Jan 2009 13:07:18 +0000
Message-ID: <1232456838-10025-2-git-send-email-steve.glendinning@smsc.com>
References: <1232456838-10025-1-git-send-email-steve.glendinning@smsc.com>
Cc: David Miller <davem@davemloft.net>,
	David Brownell <david-b@pacbell.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sandgatehouse.force9.co.uk ([84.92.144.20]:48199 "EHLO
	kensington.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754995AbZATNbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 08:31:48 -0500
In-Reply-To: <1232456838-10025-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Improve usbnet's devdbg to always type-check diagnostic arguments,
like dev_dbg (device.h).  This makes no change to the resulting size of
usbnet modules.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
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
1.6.0.6

