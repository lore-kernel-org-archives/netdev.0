From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [PATCH RFC 2/3] Introduce huawei_cdc_ncm driver
Date: Tue, 2 Jul 2013 22:13:29 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1307022210470.26010@eeeadesso>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso> <87wqp9xja5.fsf@nemi.mork.no> <alpine.LNX.2.02.1307021855270.19053@eeeadesso> <alpine.LNX.2.02.1307022202570.26010@eeeadesso> <alpine.LNX.2.02.1307022207060.26010@eeeadesso>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:56805 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755262Ab3GBUNL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 16:13:11 -0400
Received: by mail-wg0-f53.google.com with SMTP id y10so5082187wgg.8
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 13:13:10 -0700 (PDT)
In-Reply-To: <alpine.LNX.2.02.1307022207060.26010@eeeadesso>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch, introduce the huawei_cdc_ncm driver, modifying the build 
infrastructure as needed.

Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>


diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 287cc62..33cb175 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -246,6 +246,18 @@ config USB_NET_CDC_NCM
 	    * ST-Ericsson M343 HSPA Mobile Broadband Modem (reference design)
 	    * Ericsson F5521gw Mobile Broadband Module
 
+config USB_NET_HUAWEI_CDC_NCM
+	tristate "Huawei-style CDC NCM support"
+	depends on USB_USBNET
+	default y
+	select USB_WDM
+	select USB_NET_CDC_NCM
+	help
+		This driver aims to support huawei-style NCM devices, that use ncm as a 
+		transport for other protols.
+		To compile this driver as a module, choose M here: the module will be 
+		called huawei_cdc_ncm.
+
 config USB_NET_CDC_MBIM
 	tristate "CDC MBIM support"
 	depends on USB_USBNET
diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
index 9ab5c9d..12a0279 100644
--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -31,6 +31,7 @@ obj-$(CONFIG_USB_IPHETH)	+= ipheth.o
 obj-$(CONFIG_USB_SIERRA_NET)	+= sierra_net.o
 obj-$(CONFIG_USB_NET_CX82310_ETH)	+= cx82310_eth.o
 obj-$(CONFIG_USB_NET_CDC_NCM)	+= cdc_ncm.o
+obj-$(CONFIG_USB_NET_HUAWEI_CDC_NCM)	+= huawei_cdc_ncm.o
 obj-$(CONFIG_USB_VL600)		+= lg-vl600.o
 obj-$(CONFIG_USB_NET_QMI_WWAN)	+= qmi_wwan.o
 obj-$(CONFIG_USB_NET_CDC_MBIM)	+= cdc_mbim.o
