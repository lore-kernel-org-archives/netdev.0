From: Rajat Jain <rajatja@google.com>
Subject: [PATCH v5 1/3] Bluetooth: btusb: Use an error label for error paths
Date: Thu, 12 Jan 2017 10:01:05 -0800
Message-ID: <20170112180107.63244-1-rajatja@google.com>
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
v5: same as v4
v4: same as v3
v3: Added Brian's "Reviewed-by"
v2: same as v1

 drivers/bluetooth/btusb.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index 2f633df9f4e6..ce22cefceed1 100644
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
2.11.0.390.gc69c2f50cf-goog
