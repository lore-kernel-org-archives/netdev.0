From: Joe Perches <joe@perches.com>
Subject: [PATCH 3] drivers/net/usb/qcusbnet: Spelling and extern int debug
 cleanups
Date: Tue, 28 Sep 2010 20:09:24 -0700
Message-ID: <1285729764.1866.161.camel@Joe-Laptop>
References: <20100928171026.GB6083@google.com>
	 <cover.1285727642.git.joe@perches.com>
	 <0aa502d0e385f2333f8bc12dafdcde88e5ca0262.1285727642.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dbrownell@users.sourceforge.net,
	mjg59@srcf.ucam.org, jglasgow@google.com, msb@google.com,
	olofj@google.com
To: Elly Jones <ellyjones@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2532 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751832Ab0I2DJ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Sep 2010 23:09:26 -0400
In-Reply-To: <0aa502d0e385f2333f8bc12dafdcde88e5ca0262.1285727642.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some miscellaneous typo cleanups.
Add missing newlines to DBG messages.
"debug" is not a good global variable name, use qcusbnet_debug instead.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/usb/qcusbnet/qcusbnet.c  |   10 +++++-----
 drivers/net/usb/qcusbnet/qmidevice.c |    6 +++---
 drivers/net/usb/qcusbnet/structs.h   |    2 +-
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/usb/qcusbnet/qcusbnet.c b/drivers/net/usb/qcusbnet/qcusbnet.c
index 54a354e..7e218a8 100644
--- a/drivers/net/usb/qcusbnet/qcusbnet.c
+++ b/drivers/net/usb/qcusbnet/qcusbnet.c
@@ -25,7 +25,7 @@
 #define DRIVER_AUTHOR "Qualcomm Innovation Center"
 #define DRIVER_DESC "QCUSBNet2k"
 
-int debug;
+int qcusbnet_debug;
 static struct class *devclass;
 
 int qc_suspend(struct usb_interface *iface, pm_message_t event)
@@ -558,7 +558,7 @@ int qcnet_probe(struct usb_interface *iface, const struct usb_device_id *vidpids
 
 	dev = kmalloc(sizeof(struct qcusbnet), GFP_KERNEL);
 	if (!dev) {
-		DBG("falied to allocate device buffers");
+		DBG("failed to allocate device buffers\n");
 		return -ENOMEM;
 	}
 
@@ -568,7 +568,7 @@ int qcnet_probe(struct usb_interface *iface, const struct usb_device_id *vidpids
 
 	netdevops = kmalloc(sizeof(struct net_device_ops), GFP_KERNEL);
 	if (!netdevops) {
-		DBG("falied to allocate net device ops");
+		DBG("failed to allocate net device ops\n");
 		return -ENOMEM;
 	}
 	memcpy(netdevops, usbnet->net->netdev_ops, sizeof(struct net_device_ops));
@@ -645,5 +645,5 @@ MODULE_AUTHOR(DRIVER_AUTHOR);
 MODULE_DESCRIPTION(DRIVER_DESC);
 MODULE_LICENSE("Dual BSD/GPL");
 
-module_param(debug, bool, S_IRUGO | S_IWUSR);
-MODULE_PARM_DESC(debug, "Debuging enabled or not");
+module_param(qcusbnet_debug, bool, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(qcusbnet_debug, "Debugging enabled or not");
diff --git a/drivers/net/usb/qcusbnet/qmidevice.c b/drivers/net/usb/qcusbnet/qmidevice.c
index 5150453..d1cb341 100755
--- a/drivers/net/usb/qcusbnet/qmidevice.c
+++ b/drivers/net/usb/qcusbnet/qmidevice.c
@@ -54,7 +54,7 @@ struct qmihandle {
 	struct qcusbnet *dev;
 };
 
-extern int debug;
+extern int qcusbnet_debug;
 static int qcusbnet2k_fwdelay;
 
 static bool device_valid(struct qcusbnet *dev);
@@ -339,12 +339,12 @@ int qc_startread(struct qcusbnet *dev)
 void qc_stopread(struct qcusbnet *dev)
 {
 	if (dev->qmi.readurb) {
-		DBG("Killng read URB\n");
+		DBG("Killing read URB\n");
 		usb_kill_urb(dev->qmi.readurb);
 	}
 
 	if (dev->qmi.inturb) {
-		DBG("Killng int URB\n");
+		DBG("Killing int URB\n");
 		usb_kill_urb(dev->qmi.inturb);
 	}
 
diff --git a/drivers/net/usb/qcusbnet/structs.h b/drivers/net/usb/qcusbnet/structs.h
index 2999e62..7a89c5c 100755
--- a/drivers/net/usb/qcusbnet/structs.h
+++ b/drivers/net/usb/qcusbnet/structs.h
@@ -33,7 +33,7 @@
 
 #define DBG(fmt, arg...)						\
 do {									\
-	if (debug == 1)							\
+	if (qcusbnet_debug == 1)					\
 		printk(KERN_INFO "QCUSBNet2k::%s " fmt, __func__, ##arg); \
 } while (0)
 


