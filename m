From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/2] drivers/net/usb/qcusbnet/qmidevice: Remove printhex, use print_hex_dump
Date: Tue, 28 Sep 2010 19:39:58 -0700
Message-ID: <fbf3cb73a727589a5c9921eba8b7a53b307c4e76.1285727642.git.joe@perches.com>
References: <20100928171026.GB6083@google.com> <cover.1285727642.git.joe@perches.com>
Cc: netdev@vger.kernel.org, dbrownell@users.sourceforge.net,
	mjg59@srcf.ucam.org, jglasgow@google.com, msb@google.com,
	olofj@google.com
To: Elly Jones <ellyjones@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2515 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751192Ab0I2CkB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Sep 2010 22:40:01 -0400
In-Reply-To: <cover.1285727642.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just use the normal kernel facility.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/usb/qcusbnet/qmidevice.c |   34 ++++++++--------------------------
 drivers/net/usb/qcusbnet/qmidevice.h |    1 -
 2 files changed, 8 insertions(+), 27 deletions(-)

diff --git a/drivers/net/usb/qcusbnet/qmidevice.c b/drivers/net/usb/qcusbnet/qmidevice.c
index da7e42d..5150453 100755
--- a/drivers/net/usb/qcusbnet/qmidevice.c
+++ b/drivers/net/usb/qcusbnet/qmidevice.c
@@ -113,29 +113,6 @@ static bool device_valid(struct qcusbnet *dev)
 	return dev && dev->valid;
 }
 
-void printhex(const void *data, size_t size)
-{
-	const u8 *cdata = data;
-	char *buf;
-	size_t pos;
-
-	buf = kmalloc(size * 3 + 1, GFP_ATOMIC);
-	if (!buf) {
-		DBG("Unable to allocate buffer\n");
-		return;
-	}
-
-	memset(buf, 0 , size * 3 + 1);
-
-	for (pos = 0; pos < size; pos++) {
-		snprintf(buf + (pos * 3), 4, "%02X ", cdata[pos]);
-	}
-
-	DBG("   : %s\n", buf);
-
-	kfree(buf);
-}
-
 void qc_setdown(struct qcusbnet *dev, u8 reason)
 {
 	set_bit(reason, &dev->down);
@@ -188,7 +165,8 @@ static void read_callback(struct urb *urb)
 	data = urb->transfer_buffer;
 	size = urb->actual_length;
 
-	printhex(data, size);
+	print_hex_dump(KERN_INFO, "QCUSBNet2k: ", DUMP_PREFIX_OFFSET,
+		       16, 1, data, size, true);
 
 	result = qmux_parse(&cid, data, size);
 	if (result < 0) {
@@ -276,7 +254,10 @@ static void int_callback(struct urb *urb)
 			}
 		} else {
 			DBG("ignoring invalid interrupt in packet\n");
-			printhex(urb->transfer_buffer, urb->actual_length);
+			print_hex_dump(KERN_INFO, "QCUSBNet2k: ",
+				       DUMP_PREFIX_OFFSET, 16, 1,
+				       urb->transfer_buffer,
+				       urb->actual_length, true);
 		}
 	}
 
@@ -541,7 +522,8 @@ static int write_sync(struct qcusbnet *dev, char *buf, int size, u16 cid)
 			     NULL, dev);
 
 	DBG("Actual Write:\n");
-	printhex(buf, size);
+	print_hex_dump(KERN_INFO,  "QCUSBNet2k: ", DUMP_PREFIX_OFFSET,
+		       16, 1, buf, size, true);
 
 	sema_init(&sem, 0);
 
diff --git a/drivers/net/usb/qcusbnet/qmidevice.h b/drivers/net/usb/qcusbnet/qmidevice.h
index 39a4b7f..5274a0d 100755
--- a/drivers/net/usb/qcusbnet/qmidevice.h
+++ b/drivers/net/usb/qcusbnet/qmidevice.h
@@ -22,7 +22,6 @@
 #include "structs.h"
 #include "qmi.h"
 
-void printhex(const void *data, size_t size);
 void qc_setdown(struct qcusbnet *dev, u8 reason);
 void qc_cleardown(struct qcusbnet *dev, u8 reason);
 bool qc_isdown(struct qcusbnet *dev, u8 reason);
-- 
1.7.3.1.g432b3.dirty

