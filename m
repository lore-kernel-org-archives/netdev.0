From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 14/37] drivers/net/wireless/ath/ath9k: Use kmemdup
Date: Sat, 15 May 2010 23:17:19 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005152316580.21345__36765.8080337152$1273958288$gmane$org@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Jouni Malinen <jmalinen@atheros.com>,
	Sujith Manoharan <Sujith.Manoharan@atheros.com>,
	Vasanthakumar Thiagarajan <vasanth@atheros.com>,
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:46709 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753833Ab0EOVRY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 May 2010 17:17:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

Use kmemdup when some other buffer is immediately copied into the
allocated region.

A simplified version of the semantic patch that makes this change is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression from,to,size,flag;
statement S;
@@

-  to = \(kmalloc\|kzalloc\)(size,flag);
+  to = kmemdup(from,size,flag);
   if (to==NULL || ...) S
-  memcpy(to, from, size);
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/wireless/ath/ath9k/hif_usb.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff -u -p a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireless/ath/ath9k/hif_usb.c
--- a/drivers/net/wireless/ath/ath9k/hif_usb.c
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
@@ -901,12 +901,10 @@ static void ath9k_hif_usb_reboot(struct 
 	void *buf;
 	int ret;
 
-	buf = kmalloc(4, GFP_KERNEL);
+	buf = kmemdup(&reboot_cmd, 4, GFP_KERNEL);
 	if (!buf)
 		return;
 
-	memcpy(buf, &reboot_cmd, 4);
-
 	ret = usb_bulk_msg(udev, usb_sndbulkpipe(udev, USB_REG_OUT_PIPE),
 			   buf, 4, NULL, HZ);
 	if (ret)
