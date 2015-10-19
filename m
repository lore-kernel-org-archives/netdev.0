From: Oliver Neukum <oneukum@suse.com>
Subject: [PATCH 3/3] CDC parser: add dependencies
Date: Mon, 19 Oct 2015 13:48:41 +0200
Message-ID: <1445255321-13029-4-git-send-email-oneukum@suse.com>
References: <1445255321-13029-1-git-send-email-oneukum@suse.com>
Cc: Oliver Neukum <oneukum@suse.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	gregKH@linuxfoundation.org, linuxusb-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45115 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752401AbbJSLu2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2015 07:50:28 -0400
In-Reply-To: <1445255321-13029-1-git-send-email-oneukum@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using the common parser for CDC extra headers means
that cdc-acm and cdc-wdm need to select usbnet

Signed-off-by: Oliver Neukum <oneukum@suse.com>
---
 drivers/net/usb/Kconfig   | 10 +++++-----
 drivers/usb/class/Kconfig |  2 ++
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 3a8a36c..8cf0eba 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -262,7 +262,7 @@ config USB_NET_CDC_NCM
 
 config USB_NET_HUAWEI_CDC_NCM
 	tristate "Huawei NCM embedded AT channel support"
-	depends on USB_USBNET
+	select USB_USBNET
 	select USB_WDM
 	select USB_NET_CDC_NCM
 	help
@@ -277,7 +277,7 @@ config USB_NET_HUAWEI_CDC_NCM
 
 config USB_NET_CDC_MBIM
 	tristate "CDC MBIM support"
-	depends on USB_USBNET
+	select USB_USBNET
 	select USB_WDM
 	select USB_NET_CDC_NCM
 	help
@@ -381,7 +381,7 @@ config USB_NET_MCS7830
 
 config USB_NET_RNDIS_HOST
 	tristate "Host for RNDIS and ActiveSync devices"
-	depends on USB_USBNET
+	select USB_USBNET
 	select USB_NET_CDCETHER
 	help
 	  This option enables hosting "Remote NDIS" USB networking links,
@@ -466,7 +466,7 @@ config USB_KC2190
 
 config USB_NET_ZAURUS
 	tristate "Sharp Zaurus (stock ROMs) and compatible"
-	depends on USB_USBNET
+	select USB_USBNET
 	select USB_NET_CDCETHER
 	select CRC32
 	default y
@@ -502,7 +502,7 @@ config USB_NET_KALMIA
 
 config USB_NET_QMI_WWAN
 	tristate "QMI WWAN driver for Qualcomm MSM based 3G and LTE modems"
-	depends on USB_USBNET
+	select USB_USBNET
 	select USB_WDM
 	help
 	  Support WWAN LTE/3G devices based on Qualcomm Mobile Data Modem
diff --git a/drivers/usb/class/Kconfig b/drivers/usb/class/Kconfig
index bb8b736..e3c05b2 100644
--- a/drivers/usb/class/Kconfig
+++ b/drivers/usb/class/Kconfig
@@ -6,6 +6,7 @@ comment "USB Device Class drivers"
 config USB_ACM
 	tristate "USB Modem (CDC ACM) support"
 	depends on TTY
+	select USB_USBNET
 	---help---
 	  This driver supports USB modems and ISDN adapters which support the
 	  Communication Device Class Abstract Control Model interface.
@@ -29,6 +30,7 @@ config USB_PRINTER
 
 config USB_WDM
 	tristate "USB Wireless Device Management support"
+	select USB_USBNET
 	---help---
 	  This driver supports the WMC Device Management functionality
 	  of cell phones compliant to the CDC WMC specification. You can use
-- 
2.1.4
