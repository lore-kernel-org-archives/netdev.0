From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [net-2.6 2.6.33] wimax/i2400m: Add support for more i6x50 SKUs
Date: Fri, 22 Jan 2010 15:14:41 -0800
Message-ID: <b81124696e6a47d5db02b2b3561d66d1392b0f2f.1264138318.git.inaky@linux.intel.com>
References: <cover.1264138318.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:58837 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755112Ab0AVXRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 18:17:15 -0500
In-Reply-To: <cover.1264138318.git.inaky@linux.intel.com>
In-Reply-To: <cover.1264138318.git.inaky@linux.intel.com>
References: <cover.1264138318.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Intel WiMax Wireless Link 6050 can show under more than one USB
ID. Add support for all, introducing a generic flag (i2400mu->i6050)
that denotes a 6x50 based device.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/i2400m-usb.h |    2 ++
 drivers/net/wimax/i2400m/usb.c        |   12 +++++++++++-
 2 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/i2400m-usb.h b/drivers/net/wimax/i2400m/i2400m-usb.h
index 5cc0f27..2d7c96d 100644
--- a/drivers/net/wimax/i2400m/i2400m-usb.h
+++ b/drivers/net/wimax/i2400m/i2400m-usb.h
@@ -151,6 +151,7 @@ enum {
 
 	/* Device IDs */
 	USB_DEVICE_ID_I6050 = 0x0186,
+	USB_DEVICE_ID_I6050_2 = 0x0188,
 };
 
 
@@ -234,6 +235,7 @@ struct i2400mu {
 	u8 rx_size_auto_shrink;
 
 	struct dentry *debugfs_dentry;
+	unsigned i6050:1;	/* 1 if this is a 6050 based SKU */
 };
 
 
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index 3b48681..98f4f8c 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -478,7 +478,16 @@ int i2400mu_probe(struct usb_interface *iface,
 	i2400m->bus_bm_wait_for_ack = i2400mu_bus_bm_wait_for_ack;
 	i2400m->bus_bm_mac_addr_impaired = 0;
 
-	if (id->idProduct == USB_DEVICE_ID_I6050) {
+	switch (id->idProduct) {
+	case USB_DEVICE_ID_I6050:
+	case USB_DEVICE_ID_I6050_2:
+		i2400mu->i6050 = 1;
+		break;
+	default:
+		break;
+	}
+
+	if (i2400mu->i6050) {
 		i2400m->bus_fw_names = i2400mu_bus_fw_names_6050;
 		i2400mu->endpoint_cfg.bulk_out = 0;
 		i2400mu->endpoint_cfg.notification = 3;
@@ -719,6 +728,7 @@ int i2400mu_post_reset(struct usb_interface *iface)
 static
 struct usb_device_id i2400mu_id_table[] = {
 	{ USB_DEVICE(0x8086, USB_DEVICE_ID_I6050) },
+	{ USB_DEVICE(0x8086, USB_DEVICE_ID_I6050_2) },
 	{ USB_DEVICE(0x8086, 0x0181) },
 	{ USB_DEVICE(0x8086, 0x1403) },
 	{ USB_DEVICE(0x8086, 0x1405) },
-- 
1.6.2.5

