From: Rajat Jain <rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v4 1/3] Bluetooth: btusb: Use an error label for error paths
Date: Wed, 21 Dec 2016 12:33:50 -0800
Message-ID: <1482352432-38302-1-git-send-email-rajatja@google.com>
Cc: Rajat Jain <rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, rajatxjain-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
        Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
        Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Wei-Ning Huang <wnhuang-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Xinming Hu <huxm-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Brian Norris <briannorris-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Use a label to remove the repetetive cleanup, for error cases.

Signed-off-by: Rajat Jain <rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Reviewed-by: Brian Norris <briannorris-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
v4: same as v3
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
