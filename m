From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 1/1] net: reduce USB network driver config options.
Date: Tue, 5 Aug 2014 23:10:52 +0200
Message-ID: <20140805211052.GA29600@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-usb@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43094 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020AbaHEVK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 17:10:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>

USB network drivers are already handled in drivers/net/usb/Kconfig.
Let's save the maintenance burden of dependencies in drivers/net/Makefile.

The newly introduced USB_NET_DRIVERS umbrella config option defaults
to 'y' so as to minimize the changes of behavior.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/Makefile    |  9 +--------
 drivers/net/usb/Kconfig | 13 ++++++++-----
 2 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index fa49d45..61aefdd 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -61,14 +61,7 @@ obj-$(CONFIG_VMXNET3) += vmxnet3/
 obj-$(CONFIG_XEN_NETDEV_FRONTEND) += xen-netfront.o
 obj-$(CONFIG_XEN_NETDEV_BACKEND) += xen-netback/
 
-obj-$(CONFIG_USB_CATC)          += usb/
-obj-$(CONFIG_USB_KAWETH)        += usb/
-obj-$(CONFIG_USB_PEGASUS)       += usb/
-obj-$(CONFIG_USB_RTL8150)       += usb/
-obj-$(CONFIG_USB_HSO)		+= usb/
-obj-$(CONFIG_USB_USBNET)        += usb/
-obj-$(CONFIG_USB_IPHETH)        += usb/
-obj-$(CONFIG_USB_CDC_PHONET)   += usb/
+obj-$(CONFIG_USB_NET_DRIVERS) += usb/
 
 obj-$(CONFIG_HYPERV_NET) += hyperv/
 obj-$(CONFIG_NTB_NETDEV) += ntb_netdev.o
diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 7e7269f..9f194a0 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -1,12 +1,16 @@
 #
 # USB Network devices configuration
 #
-comment "Networking support is needed for USB Network Adapter support"
-	depends on USB && !NET
+comment "Host-side USB support is needed for USB Network Adapter support"
+	depends on !USB && NET
 
-menu "USB Network Adapters"
+menuconfig USB_NET_DRIVERS
+	bool "USB Network Adapters"
+	default y
 	depends on USB && NET
 
+if USB_NET_DRIVERS
+
 config USB_CATC
 	tristate "USB CATC NetMate-based Ethernet device support"
 	select CRC32
@@ -568,5 +572,4 @@ config USB_VL600
 
 	  http://ubuntuforums.org/showpost.php?p=10589647&postcount=17
 
-
-endmenu
+endif # USB_NET_DRIVERS
-- 
1.9.3
