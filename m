From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net] r8152: fix setting RTL8152_UNPLUG
Date: Tue, 30 Sep 2014 16:48:01 +0800
Message-ID: <1394712342-15778-50-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The flag of RTL8152_UNPLUG should only be set when the device is
unplugged, not each time the rtl8152_disconnect() is called.
Otherwise, the device wouldn't be stopped normally.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index e039442..f68a4e6 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3576,7 +3576,11 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 
 	usb_set_intfdata(intf, NULL);
 	if (tp) {
-		set_bit(RTL8152_UNPLUG, &tp->flags);
+		struct usb_device *udev = tp->udev;
+
+		if (udev->state == USB_STATE_NOTATTACHED)
+			set_bit(RTL8152_UNPLUG, &tp->flags);
+
 		tasklet_kill(&tp->tl);
 		unregister_netdev(tp->netdev);
 		tp->rtl_ops.unload(tp);
-- 
1.9.3
