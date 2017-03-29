From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 7/7] NFC: nfcmrvl_usb: use interface as phy device
Date: Wed, 29 Mar 2017 18:21:12 +0200
Message-ID: <20170329162112.18121-8-johan@kernel.org>
References: <20170329162112.18121-1-johan@kernel.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
        Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
        Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170329162112.18121-1-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the USB-interface rather than parent USB-device device, which is
what this driver binds to, when registering the nci device.

Note that using the right device is important when dealing with device-
managed resources as the interface can be unbound independently of the
parent device.

Also note that private device pointer had already been set by
nfcmrvl_nci_register_dev() so the redundant assignment can therefore be
removed.

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/nfc/nfcmrvl/usb.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/nfc/nfcmrvl/usb.c b/drivers/nfc/nfcmrvl/usb.c
index 585a0f20835b..728b3321842d 100644
--- a/drivers/nfc/nfcmrvl/usb.c
+++ b/drivers/nfc/nfcmrvl/usb.c
@@ -341,15 +341,13 @@ static int nfcmrvl_probe(struct usb_interface *intf,
 	init_usb_anchor(&drv_data->deferred);
 
 	priv = nfcmrvl_nci_register_dev(NFCMRVL_PHY_USB, drv_data, &usb_ops,
-					&drv_data->udev->dev, &config);
+					&intf->dev, &config);
 	if (IS_ERR(priv))
 		return PTR_ERR(priv);
 
 	drv_data->priv = priv;
 	drv_data->priv->support_fw_dnld = false;
 
-	priv->dev = &drv_data->udev->dev;
-
 	usb_set_intfdata(intf, drv_data);
 
 	return 0;
-- 
2.12.2
