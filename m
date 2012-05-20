From: Andrew Bird <ajb@spheresystems.co.uk>
Subject: [PATCH 3/3] USB: qmi_wwan: Add ZTE (Vodafone) K3520-Z
Date: Sun, 20 May 2012 09:28:38 +0100
Message-ID: <1337502518-1444-3-git-send-email-ajb@spheresystems.co.uk>
References: <1337502518-1444-1-git-send-email-ajb@spheresystems.co.uk>
Cc: gregkh@linuxfoundation.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Bird <ajb@spheresystems.co.uk>
To: bjorn@mork.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337502518-1444-1-git-send-email-ajb@spheresystems.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Andrew Bird <ajb@spheresystems.co.uk>
---
 drivers/net/usb/qmi_wwan.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 0646e45..f64dac3 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -356,6 +356,15 @@ static const struct driver_info	qmi_wwan_gobi = {
 };
 
 /* ZTE suck at making USB descriptors */
+static const struct driver_info	qmi_wwan_force_int1 = {
+	.description	= "Qualcomm WWAN/QMI device",
+	.flags		= FLAG_WWAN,
+	.bind		= qmi_wwan_bind_shared,
+	.unbind		= qmi_wwan_unbind_shared,
+	.manage_power	= qmi_wwan_manage_power,
+	.data		= BIT(1), /* interface whitelist bitmap */
+};
+
 static const struct driver_info	qmi_wwan_force_int4 = {
 	.description	= "Qualcomm WWAN/QMI device",
 	.flags		= FLAG_WWAN,
@@ -430,6 +439,15 @@ static const struct usb_device_id products[] = {
 		.bInterfaceProtocol = 0xff,
 		.driver_info        = (unsigned long)&qmi_wwan_force_int4,
 	},
+	{	/* ZTE (Vodafone) K3520-Z */
+		.match_flags	    = USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_MATCH_INT_INFO,
+		.idVendor           = 0x19d2,
+		.idProduct          = 0x0055,
+		.bInterfaceClass    = 0xff,
+		.bInterfaceSubClass = 0xff,
+		.bInterfaceProtocol = 0xff,
+		.driver_info        = (unsigned long)&qmi_wwan_force_int1,
+	},
 	{	/* ZTE (Vodafone) K3565-Z */
 		.match_flags	    = USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_MATCH_INT_INFO,
 		.idVendor           = 0x19d2,
-- 
1.7.5.4
