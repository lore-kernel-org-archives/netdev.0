From: Rajat Jain <rajatja@google.com>
Subject: [PATCH 1/3] Bluetooth: btusb: Use an error label for error paths
Date: Wed, 14 Dec 2016 11:12:57 -0800
Message-ID: <1481742779-15105-1-git-send-email-rajatja@google.com>
Cc: Rajat Jain <rajatja@google.com>, rajatxjain@gmail.com
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        Amitkumar Karwar <akarwar@marvell.com>,
        Wei-Ning Huang <wnhuang@chromium.org>,
        Xinming Hu <huxm@marvell.com>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        Brian Norris <briannorris@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:35823 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756196AbcLNTNQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 14:13:16 -0500
Received: by mail-pg0-f41.google.com with SMTP id p66so10941058pga.2
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2016 11:13:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use a label to remove the repetetive cleanup, for error cases.
(This label will also be used in subsequent patches).

Signed-off-by: Rajat Jain <rajatja@google.com>
---
 drivers/bluetooth/btusb.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index 2f633df..ce22cef 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -2991,18 +2991,15 @@ static int btusb_probe(struct usb_interface *intf,
 		err = usb_set_interface(data->udev, 0, 0);
 		if (err < 0) {
 			BT_ERR("failed to set interface 0, alt 0 %d", err);
-			hci_free_dev(hdev);
-			return err;
+			goto out_free_dev;
 		}
 	}
 
 	if (data->isoc) {
 		err = usb_driver_claim_interface(&btusb_driver,
 						 data->isoc, data);
-		if (err < 0) {
-			hci_free_dev(hdev);
-			return err;
-		}
+		if (err < 0)
+			goto out_free_dev;
 	}
 
 #ifdef CONFIG_BT_HCIBTUSB_BCM
@@ -3016,14 +3013,16 @@ static int btusb_probe(struct usb_interface *intf,
 #endif
 
 	err = hci_register_dev(hdev);
-	if (err < 0) {
-		hci_free_dev(hdev);
-		return err;
-	}
+	if (err < 0)
+		goto out_free_dev;
 
 	usb_set_intfdata(intf, data);
 
 	return 0;
+
+out_free_dev:
+	hci_free_dev(hdev);
+	return err;
 }
 
 static void btusb_disconnect(struct usb_interface *intf)
-- 
2.8.0.rc3.226.g39d4020
