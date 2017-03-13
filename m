From: Johan Hovold <johan@kernel.org>
Subject: [PATCH] net: wimax/i2400m: fix NULL-deref at probe
Date: Mon, 13 Mar 2017 13:42:03 +0100
Message-ID: <20170313124203.28490-1-johan@kernel.org>
Cc: linux-wimax@intel.com, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
        Johan Hovold <johan@kernel.org>,
        Inaky Perez-Gonzalez <inaky@linux.intel.com>
To: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to check the number of endpoints to avoid dereferencing a
NULL-pointer or accessing memory beyond the endpoint array should a
malicious device lack the expected endpoints.

The endpoints are specifically dereferenced in the i2400m_bootrom_init
path during probe (e.g. in i2400mu_tx_bulk_out).

Fixes: f398e4240fce ("i2400m/USB: probe/disconnect, dev init/shutdown
and reset backends")
Cc: Inaky Perez-Gonzalez <inaky@linux.intel.com>

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/wimax/i2400m/usb.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index e7f5910a6519..f8eb66ef2944 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -467,6 +467,9 @@ int i2400mu_probe(struct usb_interface *iface,
 	struct i2400mu *i2400mu;
 	struct usb_device *usb_dev = interface_to_usbdev(iface);
 
+	if (iface->cur_altsetting->desc.bNumEndpoints < 4)
+		return -ENODEV;
+
 	if (usb_dev->speed != USB_SPEED_HIGH)
 		dev_err(dev, "device not connected as high speed\n");
 
-- 
2.12.0
