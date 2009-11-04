From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/3 06/13] wimax/i2400m: implement .reset_resume in USB subdriver
Date: Wed,  4 Nov 2009 13:39:57 -0800
Message-ID: <1a5a73c0c5459f991b871855eb36099df65ecb7e.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20707 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932743AbZKDVmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:07 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current driver didn't implement the .reset_resume method. The i2400m
normally always reset on a comeback from system standby/hibernation.

This requires previously applied commits to cache the firmware image
file.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/usb.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index 77d08d9..07653de 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -624,6 +624,21 @@ out:
 
 
 static
+int i2400mu_reset_resume(struct usb_interface *iface)
+{
+	int result;
+	struct device *dev = &iface->dev;
+	struct i2400mu *i2400mu = usb_get_intfdata(iface);
+	struct i2400m *i2400m = &i2400mu->i2400m;
+
+	d_fnstart(3, dev, "(iface %p)\n", iface);
+	result = i2400m_dev_reset_handle(i2400m, "device reset on resume");
+	d_fnend(3, dev, "(iface %p) = %d\n", iface, result);
+	return result < 0 ? result : 0;
+}
+
+
+static
 struct usb_device_id i2400mu_id_table[] = {
 	{ USB_DEVICE(0x8086, USB_DEVICE_ID_I6050) },
 	{ USB_DEVICE(0x8086, 0x0181) },
@@ -643,6 +658,7 @@ struct usb_driver i2400mu_driver = {
 	.name = KBUILD_MODNAME,
 	.suspend = i2400mu_suspend,
 	.resume = i2400mu_resume,
+	.reset_resume = i2400mu_reset_resume,
 	.probe = i2400mu_probe,
 	.disconnect = i2400mu_disconnect,
 	.id_table = i2400mu_id_table,
-- 
1.6.2.5

