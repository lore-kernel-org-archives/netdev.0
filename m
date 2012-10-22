From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH v2 net-next 10/13] net: cdc_mbim: build the MBIM driver
Date: Mon, 22 Oct 2012 22:56:37 +0200
Message-ID: <1350939400-27209-11-git-send-email-bjorn@mork.no>
References: <1350939400-27209-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Greg Suarez <gpsuarez2512@gmail.com>,
	"Fangxiaozhi (Franko)" <fangxiaozhi@huawei.com>,
	Dan Williams <dcbw@redhat.com>,
	Aleksander Morgado <aleksander@lanedo.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:48605 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756366Ab2JVU5W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2012 16:57:22 -0400
In-Reply-To: <1350939400-27209-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/Kconfig  |   18 ++++++++++++++++++
 drivers/net/usb/Makefile |    1 +
 2 files changed, 19 insertions(+)

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index c1ae769..2ab8043 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -219,6 +219,24 @@ config USB_NET_CDC_NCM
 	    * ST-Ericsson M343 HSPA Mobile Broadband Modem (reference design)
 	    * Ericsson F5521gw Mobile Broadband Module
=20
+config USB_NET_CDC_MBIM
+	tristate "CDC MBIM support"
+	depends on USB_USBNET
+	select USB_WDM
+	select USB_NET_CDC_NCM
+	help
+	  This driver provides support for CDC MBIM (Mobile Broadband
+	  Interface Model) devices. The CDC MBIM specification is
+	  available from <http://www.usb.org/>.
+
+	  MBIM devices require configuration using the management
+	  protocol defined by the MBIM specification.  This driver
+	  provides unfiltered access to the MBIM control channel
+	  through the associated /dev/cdc-wdmx character device.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called cdc_mbim.
+
 config USB_NET_DM9601
 	tristate "Davicom DM9601 based USB 1.1 10/100 ethernet devices"
 	depends on USB_USBNET
diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
index bf06300..4786913 100644
--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -31,4 +31,5 @@ obj-$(CONFIG_USB_NET_CX82310_ETH)	+=3D cx82310_eth.o
 obj-$(CONFIG_USB_NET_CDC_NCM)	+=3D cdc_ncm.o
 obj-$(CONFIG_USB_VL600)		+=3D lg-vl600.o
 obj-$(CONFIG_USB_NET_QMI_WWAN)	+=3D qmi_wwan.o
+obj-$(CONFIG_USB_NET_CDC_MBIM)	+=3D cdc_mbim.o
=20
--=20
1.7.10.4
