From: Vivek Bhagat <vivek.bhagat89@gmail.com>
Subject: [Patch v1] ax88179_178a: add reset functionality in reset_resume
Date: Sun, 21 Jun 2015 11:46:08 +0530
Message-ID: <CA+vmRF7nC2Ndzzt+QRj2YG7yQEtHw=3ZBuNBCqyM7nqErFoU-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vn0-f42.google.com ([209.85.216.42]:41677 "EHLO
	mail-vn0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751466AbbFUGQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 02:16:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without reset functionality in reset_resume, iperf connection does not
establish after suspend/resume however ping works at the same time.
iperf connection fails with wrong checksum error shown by tcpdump.

reset function inside reset_resume solves above bug. We have verified
this issue on ASIX based ST Lab, Cadyce dongle.

Signed-off-by: Vivek Kumar Bhagat <vivek.bhagat@samsung.com>
Signed-off-by: Praveen Kumar <praveen.k09@samsung.com>

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
