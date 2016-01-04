From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net] r8152: add reset_resume function
Date: Mon, 4 Jan 2016 14:38:46 +0800
Message-ID: <1394712342-15778-169-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

When the reset_resume() is called, the flag of SELECTIVE_SUSPEND should be
cleared and reinitialize the device, whether the SELECTIVE_SUSPEND is set
or not. If reset_resume() is called, it means the power supply is cut or the
device is reset. That is, the device wouldn't be in runtime suspend state and
the reinitialization is necessary.

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 2e32c41..2fb637a 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3525,6 +3525,14 @@ static int rtl8152_resume(struct usb_interface *intf)
 	return 0;
 }
 
+static int rtl8152_reset_resume(struct usb_interface *intf)
+{
+	struct r8152 *tp = usb_get_intfdata(intf);
+
+	clear_bit(SELECTIVE_SUSPEND, &tp->flags);
+	return rtl8152_resume(intf);
+}
+
 static void rtl8152_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct r8152 *tp = netdev_priv(dev);
@@ -4276,7 +4284,7 @@ static struct usb_driver rtl8152_driver = {
 	.disconnect =	rtl8152_disconnect,
 	.suspend =	rtl8152_suspend,
 	.resume =	rtl8152_resume,
-	.reset_resume =	rtl8152_resume,
+	.reset_resume =	rtl8152_reset_resume,
 	.pre_reset =	rtl8152_pre_reset,
 	.post_reset =	rtl8152_post_reset,
 	.supports_autosuspend = 1,
-- 
2.4.3

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
