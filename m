From: Johan Hovold <johan@kernel.org>
Subject: [PATCH] isdn/gigaset: fix NULL-deref at probe
Date: Mon, 13 Mar 2017 13:39:01 +0100
Message-ID: <20170313123901.28298-1-johan@kernel.org>
Cc: Paul Bolle <pebolle@tiscali.nl>,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
        Johan Hovold <johan@kernel.org>,
        stable <stable@vger.kernel.org>, Hansjoerg Lipp <hjlipp@web.de>
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to check the number of endpoints to avoid dereferencing a
NULL-pointer should a malicious device lack endpoints.

Fixes: cf7776dc05b8 ("[PATCH] isdn4linux: Siemens Gigaset drivers -
direct USB connection")
Cc: stable <stable@vger.kernel.org>	# 2.6.17
Cc: Hansjoerg Lipp <hjlipp@web.de>

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/isdn/gigaset/bas-gigaset.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index 11e13c56126f..2da3ff650e1d 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -2317,6 +2317,9 @@ static int gigaset_probe(struct usb_interface *interface,
 		return -ENODEV;
 	}
 
+	if (hostif->desc.bNumEndpoints < 1)
+		return -ENODEV;
+
 	dev_info(&udev->dev,
 		 "%s: Device matched (Vendor: 0x%x, Product: 0x%x)\n",
 		 __func__, le16_to_cpu(udev->descriptor.idVendor),
-- 
2.12.0
