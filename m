From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] staging: r8712u: Set device type to wlan
Date: Tue, 24 Dec 2013 11:22:54 -0600
Message-ID: <1387905774-12666-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Stable <stable@vger.kernel.org>
To: gregkh@linuxfoundation.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The latest version of NetworkManager does not recognize the device as wireless
without this change.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>
---
 drivers/staging/rtl8712/usb_intf.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/staging/rtl8712/usb_intf.c b/drivers/staging/rtl8712/usb_intf.c
index 38060ab..deb368c 100644
--- a/drivers/staging/rtl8712/usb_intf.c
+++ b/drivers/staging/rtl8712/usb_intf.c
@@ -354,6 +354,10 @@ static void disable_ht_for_spec_devid(const struct usb_device_id *pdid,
 	}
 }
 
+static const struct device_type wlan_type = {
+	.name = "wlan",
+};
+
 /*
  * drv_init() - a device potentially for us
  *
@@ -389,6 +393,7 @@ static int r871xu_drv_init(struct usb_interface *pusb_intf,
 	padapter->pusb_intf = pusb_intf;
 	usb_set_intfdata(pusb_intf, pnetdev);
 	SET_NETDEV_DEV(pnetdev, &pusb_intf->dev);
+	pnetdev->dev.type = &wlan_type;
 	/* step 2. */
 	padapter->dvobj_init = &r8712_usb_dvobj_init;
 	padapter->dvobj_deinit = &r8712_usb_dvobj_deinit;
-- 
1.8.4
