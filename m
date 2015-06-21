From: Vivek Bhagat <vivek.bhagat89-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [Patch v1] ax88179_178a: add reset functionality in reset_resume
Date: Sun, 21 Jun 2015 11:41:43 +0530
Message-ID: <CA+vmRF7e0Y1S_YXeHAL9u=Tp-Py_8NL3JzAVJceriFZ5Nq+LWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>From d178065c9e3cfa8a45ef537fae7412775339beb0 Mon Sep 17 00:00:00 2001
From: Vivek Kumar Bhagat <vivek.bhagat-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Date: Thu, 11 Jun 2015 07:23:46 -0700
Subject: [PATCH] ax88179_178a: add reset functionality in reset_resume

Without reset functionality in reset_resume, iperf connection does not
establish after suspend/resume however ping works at the same time.
iperf connection fails with wrong checksum error shown by tcpdump.

reset function inside reset_resume solves above bug. We have verified
this issue on ASIX based ST Lab, Cadyce dongle.

Signed-off-by: Vivek Kumar Bhagat <vivek.bhagat-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Praveen Kumar <praveen.k09-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>

---
 drivers/net/usb/ax88179_178a.c |   14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index e6338c1..00928c0 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -1630,6 +1630,18 @@ static int ax88179_stop(struct usbnet *dev)
  return 0;
 }

+static int ax88179_reset_resume(struct usb_interface *intf)
+{
+ struct usbnet *dev = usb_get_intfdata(intf);
+ int ret;
+
+ ret = ax88179_reset(dev);
+ if (ret < 0)
+  return ret;
+
+ return  ax88179_resume(intf);
+}
+
 static const struct driver_info ax88179_info = {
  .description = "ASIX AX88179 USB 3.0 Gigabit Ethernet",
  .bind = ax88179_bind,
@@ -1744,7 +1756,7 @@ static struct usb_driver ax88179_178a_driver = {
  .probe = usbnet_probe,
  .suspend = ax88179_suspend,
  .resume = ax88179_resume,
- .reset_resume = ax88179_resume,
+ .reset_resume = ax88179_reset_resume,
  .disconnect = usbnet_disconnect,
  .supports_autosuspend = 1,
  .disable_hub_initiated_lpm = 1,
-- 
1.7.9.5
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
