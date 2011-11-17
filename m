From: Thomas Meyer <thomas@m3y3r.de>
Subject: [PATCH] CDC NCM: Use kzalloc rather than kmalloc followed by
 memset with 0
Date: Thu, 17 Nov 2011 23:43:40 +0100
Message-ID: <1321569820.1624.264.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: oliver@neukum.name, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This considers some simple cases that are common and easy to validate
Note in particular that there are no ...s in the rule, so all of the
matched code has to be contiguous

The semantic patch that makes this change is available
in scripts/coccinelle/api/alloc/kzalloc-simple.cocci.

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
--- a/drivers/net/usb/cdc_ncm.c 2011-11-07 19:38:00.160137318 +0100
+++ b/drivers/net/usb/cdc_ncm.c 2011-11-08 09:35:34.632578608 +0100
@@ -465,12 +465,10 @@ static int cdc_ncm_bind(struct usbnet *d
 	int temp;
 	u8 iface_no;
 
-	ctx = kmalloc(sizeof(*ctx), GFP_KERNEL);
+	ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
 	if (ctx == NULL)
 		return -ENODEV;
 
-	memset(ctx, 0, sizeof(*ctx));
-
 	init_timer(&ctx->tx_timer);
 	spin_lock_init(&ctx->mtx);
 	ctx->netdev = dev->net;
