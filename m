From: Marina Makienko <makienko@ispras.ru>
Subject: [PATCH] isdn: hisax: add missing usb_free_urb
Date: Tue, 26 Feb 2013 12:26:50 +0400
Message-ID: <1361867210-13309-1-git-send-email-makienko@ispras.ru>
Cc: Marina Makienko <makienko@ispras.ru>, netdev@vger.kernel.org,
	ldv-project@linuxtesting.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ispras.ru ([83.149.199.79]:43385 "EHLO smtp.ispras.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759241Ab3BZIrd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2013 03:47:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing usb_free_urb() on failure path in st5481_setup_usb().

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Marina Makienko <makienko@ispras.ru>
---
 drivers/isdn/hisax/st5481_usb.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hisax/st5481_usb.c b/drivers/isdn/hisax/st5481_usb.c
index 017c67e..ead0a4f 100644
--- a/drivers/isdn/hisax/st5481_usb.c
+++ b/drivers/isdn/hisax/st5481_usb.c
@@ -294,13 +294,13 @@ int st5481_setup_usb(struct st5481_adapter *adapter)
 	// Allocate URBs and buffers for interrupt endpoint
 	urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!urb) {
-		return -ENOMEM;
+		goto err1;
 	}
 	intr->urb = urb;
 
 	buf = kmalloc(INT_PKT_SIZE, GFP_KERNEL);
 	if (!buf) {
-		return -ENOMEM;
+		goto err2;
 	}
 
 	endpoint = &altsetting->endpoint[EP_INT-1];
@@ -313,6 +313,14 @@ int st5481_setup_usb(struct st5481_adapter *adapter)
 			 endpoint->desc.bInterval);
 
 	return 0;
+err2:
+	usb_free_urb(intr->urb);
+	intr->urb = NULL;
+err1:
+	usb_free_urb(ctrl->urb);
+	ctrl->urb = NULL;
+
+	return -ENOMEM;
 }
 
 /*
-- 
1.7.7
