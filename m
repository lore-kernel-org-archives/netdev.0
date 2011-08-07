From: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: rtl8150: rtl8150_disconnect(...) does not need tasklet_disable(...)
Date: Sun, 7 Aug 2011 21:03:31 +0800
Message-ID: <CA+v9cxZvU0GG_zS=yQaB19qHuvjABA-ceeTasucxsY-5ZK5kMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, lud <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, petkan-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Executing cmd 'rmmod rtl8150' does not return(if your device connects
to host), the root cause is tasklet_disable() causes tasklet_kill()
block, remove it from rtl8150_disconnect().

Signed-off-by: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/rtl8150.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index 041fb7d..ef3b236 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -977,7 +977,6 @@ static void rtl8150_disconnect(struct usb_interface *intf)
 	usb_set_intfdata(intf, NULL);
 	if (dev) {
 		set_bit(RTL8150_UNPLUG, &dev->flags);
-		tasklet_disable(&dev->tl);
 		tasklet_kill(&dev->tl);
 		unregister_netdev(dev->netdev);
 		unlink_all_urbs(dev);
-- 
1.7.4.1
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
