From: Denis Joseph Barrow <D.Barow@option.com>
Subject: [PATCH] hso serial throttled tty kref fix.
Date: Thu, 15 Jan 2009 13:10:33 +0100
Message-ID: <496F27B9.3030802@option.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060800070907040203060102"
To: Linux Serial <linux-serial@vger.kernel.org>,
	Linux USB kernel mailing list <linux-usb@vger.kernel.org>,
	Linux netdev Mailing list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.option.com ([81.246.70.162]:64036 "EHLO
	mailer1.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753236AbZAOMKg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 07:10:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060800070907040203060102
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi,
This patch is for Alan Cox as it related to the tty layer.
Hopefully the hso driver is again relatively stable with this fix.

Signed-off-by: Denis Joseph Barrow <D.Barow@option.com>
---
Index: linux-2.6/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.orig/drivers/net/usb/hso.c	2009-01-15 12:45:09.000000000 +0100
+++ linux-2.6/drivers/net/usb/hso.c	2009-01-15 12:46:18.000000000 +0100
@@ -2040,8 +2040,10 @@
 			serial->curr_rx_urb_offset;
 		D1("data to push to tty");
 		while (write_length_remaining) {
-			if (test_bit(TTY_THROTTLED, &tty->flags))
+			if (test_bit(TTY_THROTTLED, &tty->flags)) {
+				tty_kref_put(tty);
 				return -1;
+			}
 			curr_write_len =  tty_insert_flip_string
 				(tty, urb->transfer_buffer +
 				 serial->curr_rx_urb_offset,
-- 
best regards,
D.J. Barrow

Linux Kernel Developer
Option NV, Gaston Geenslaan 14, 3001 Leuven, Belgium
 
T: +32 16 311 621
F: +32 16 207 164
d.barow@option.com
www.option.com

Disclaimer:
http://www.option.com/company/disclaimer.shtml

--------------060800070907040203060102
Content-Type: text/x-diff;
 name="hso_tty_kref_fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_tty_kref_fix.patch"

Fixes a missed tty_kref_put which is caused the driver
to fail to unloading when rmmoded if the hso serial port
ever gets throttled. 
Signed-off-by: Denis Joseph Barrow <D.Barow@option.com>
---
Index: linux-2.6/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.orig/drivers/net/usb/hso.c	2009-01-15 12:45:09.000000000 +0100
+++ linux-2.6/drivers/net/usb/hso.c	2009-01-15 12:46:18.000000000 +0100
@@ -2040,8 +2040,10 @@
 			serial->curr_rx_urb_offset;
 		D1("data to push to tty");
 		while (write_length_remaining) {
-			if (test_bit(TTY_THROTTLED, &tty->flags))
+			if (test_bit(TTY_THROTTLED, &tty->flags)) {
+				tty_kref_put(tty);
 				return -1;
+			}
 			curr_write_len =  tty_insert_flip_string
 				(tty, urb->transfer_buffer +
 				 serial->curr_rx_urb_offset,

--------------060800070907040203060102--
