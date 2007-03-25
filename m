From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw-mac80211: tweak reset-on-probe behaviour
Date: Mon, 26 Mar 2007 00:17:54 +0100 (BST)
Message-ID: <20070325231754.5E2267B409F@zog.reactivated.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>

This is an update to the earlier commit 8b4ebaabf12. The argument
is directly used and an error condition will be handled.

Here are some sentences about the reason for this commit. There
have been a larger number of reports of problems after rebooting
the machine. According to reports the resetting of the stick
during probe makes this problem disappear. Notify that it doesn't
help while reloading the module.

Signed-off-by: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/mac80211/zd1211rw/zd_usb.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c b/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
index 418a8ad..8867110 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_usb.c
@@ -917,7 +917,12 @@ static int probe(struct usb_interface *intf, const struct usb_device_id *id)
 		goto error;
 	}
 
-	usb_reset_device(interface_to_usbdev(intf));
+	r = usb_reset_device(udev);
+	if (r) {
+		dev_err(&intf->dev,
+			"couldn't reset usb device. Error number %d\n", r);
+		goto error;
+	}
 
 	dev = zd_mac_alloc(intf);
 	if (dev == NULL) {
-- 
1.5.0.5
