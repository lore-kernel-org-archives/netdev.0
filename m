From: Pan Bian <bianpan201603@163.com>
Subject: [PATCH 1/1] net: irda: set error code on failures
Date: Sun,  4 Dec 2016 13:27:40 +0800
Message-ID: <1480829260-4590-1-git-send-email-bianpan201603@163.com>
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pan Bian <bianpan2016@163.com>

When the calls to kzalloc() fail, the value of return variable ret may
be 0. 0 means success in this context. This patch fixes the bug,
assigning "-ENOMEM" to ret before calling kzalloc().

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188971

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 drivers/net/irda/irda-usb.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index a198946..8716b8c 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -1723,6 +1723,7 @@ static int irda_usb_probe(struct usb_interface *intf,
 	/* Don't change this buffer size and allocation without doing
 	 * some heavy and complete testing. Don't ask why :-(
 	 * Jean II */
+	ret = -ENOMEM;
 	self->speed_buff = kzalloc(IRDA_USB_SPEED_MTU, GFP_KERNEL);
 	if (!self->speed_buff)
 		goto err_out_3;
-- 
1.9.1
