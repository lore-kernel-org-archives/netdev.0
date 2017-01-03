From: Peter Chen <peter.chen-3arQi8VN3Tc@public.gmane.org>
Subject: [PATCH 1/1] net: usb: asix_devices: add .reset_resume for USB PM
Date: Tue, 3 Jan 2017 17:22:20 +0800
Message-ID: <1483435340-20371-1-git-send-email-peter.chen@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Peter Chen <peter.chen-3arQi8VN3Tc@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The USB core may call reset_resume when it fails to resume asix device.
And USB core can recovery this abnormal resume at low level driver,
the same .resume at asix driver can work too. Add .reset_resume can
avoid disconnecting after backing from system resume, and NFS can
still be mounted after this commit.

Signed-off-by: Peter Chen <peter.chen-3arQi8VN3Tc@public.gmane.org>
---
 drivers/net/usb/asix_devices.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index 6c646e2..6e98ede 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -1367,6 +1367,7 @@ static struct usb_driver asix_driver = {
 	.probe =	usbnet_probe,
 	.suspend =	asix_suspend,
 	.resume =	asix_resume,
+	.reset_resume =	asix_resume,
 	.disconnect =	usbnet_disconnect,
 	.supports_autosuspend = 1,
 	.disable_hub_initiated_lpm = 1,
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
