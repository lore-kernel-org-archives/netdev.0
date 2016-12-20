From: Rajat Jain <rajatja@google.com>
Subject: [PATCH v3 1/3] Bluetooth: btusb: Use an error label for error paths
Date: Mon, 19 Dec 2016 18:56:30 -0800
Message-ID: <1482202592-76314-1-git-send-email-rajatja@google.com>
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
        Brian Norris <briannorris@google.com>,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a label to remove the repetetive cleanup, for error cases.

Signed-off-by: Rajat Jain <rajatja@google.com>
Reviewed-by: Brian Norris <briannorris@chromium.org>
---
v3: Added Brian's "Reviewed-by"
v2: same as v1

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
