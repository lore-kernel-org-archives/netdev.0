From: Oliver Neukum <oliver@neukum.org>
Subject: [PATCH 2/3] usbnet: generic manage_power()
Date: Tue, 18 Dec 2012 15:45:52 +0100
Message-ID: <1355841952-1025-1-git-send-email-oliver@neukum.org>
Cc: Oliver Neukum <oliver@neukum.org>, Oliver Neukum <oneukum@suse.de>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:51031 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932066Ab2LROp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 09:45:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Centralise common code for manage_power() in usbnet
by making a generic simple implementation

Signed-off-by: Oliver Neukum <oneukum@suse.de>
---
 drivers/net/usb/usbnet.c   |   10 ++++++++++
 include/linux/usb/usbnet.h |    2 ++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 50ed7ab..3d4bf01 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1616,6 +1616,16 @@ void usbnet_device_suggests_idle(struct usbnet *dev)
 }
 EXPORT_SYMBOL(usbnet_device_suggests_idle);
 
+/*
+ * For devices that can do without special commands
+ */
+int usbnet_manage_power(struct usbnet *dev, int on)
+{
+	dev->intf->needs_remote_wakeup = on;
+	return 0;
+}
+EXPORT_SYMBOL(usbnet_manage_power);
+
 /*-------------------------------------------------------------------------*/
 static int __usbnet_read_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
 			     u16 value, u16 index, void *data, u16 size)
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 288b32a..bd45eb7 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -241,4 +241,6 @@ extern void usbnet_set_msglevel(struct net_device *, u32);
 extern void usbnet_get_drvinfo(struct net_device *, struct ethtool_drvinfo *);
 extern int usbnet_nway_reset(struct net_device *net);
 
+extern int usbnet_manage_power(struct usbnet *, int);
+
 #endif /* __LINUX_USB_USBNET_H */
-- 
1.7.7
