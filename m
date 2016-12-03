From: Pan Bian <bianpan2016@163.com>
Subject: [PATCH 1/1] net: usb: set error code when usb_alloc_urb fails
Date: Sat,  3 Dec 2016 19:24:48 +0800
Message-ID: <1480764288-5448-1-git-send-email-bianpan2016@163.com>
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Woojung Huh <woojung.huh@microchip.com>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        netdev@vger.kernel.org, linux-usb@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In function lan78xx_probe(), variable ret takes the errno code on
failures. However, when the call to usb_alloc_urb() fails, its value
will keeps 0. 0 indicates success in the context, which is inconsistent
with the execution result. This patch fixes the bug, assigning
"-ENOMEM" to ret when usb_alloc_urb() returns a NULL pointer.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188771

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 drivers/net/usb/lan78xx.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index db558b8..f33460c 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -3395,6 +3395,7 @@ static int lan78xx_probe(struct usb_interface *intf,
 	if (buf) {
 		dev->urb_intr = usb_alloc_urb(0, GFP_KERNEL);
 		if (!dev->urb_intr) {
+			ret = -ENOMEM;
 			kfree(buf);
 			goto out3;
 		} else {
-- 
1.9.1
