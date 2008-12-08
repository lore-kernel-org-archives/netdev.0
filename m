From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH1/1] hso modem detect fix patch against Alan Cox'es tty tree
Date: Mon, 08 Dec 2008 15:38:31 +0100
Message-ID: <493D3167.200@option.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040706000202040603090502"
Cc: Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040706000202040603090502
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Here you go good sir,

Fixed incorrect check for the modem port, this prevents
crashes caused by issueing a tiocmget_submit_urb
on endpoints which don't exist for non modem devices. 
Signed-off-by: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
---
Index: linux-2.6.28-rc7.alan/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.28-rc7.alan.orig/drivers/net/usb/hso.c	2008-12-08 15:26:00.000000000 +0100
+++ linux-2.6.28-rc7.alan/drivers/net/usb/hso.c	2008-12-08 15:28:10.000000000 +0100
@@ -2659,7 +2659,7 @@
 	serial->parent = hso_dev;
 	hso_dev->port_data.dev_serial = serial;
 
-	if (port & HSO_PORT_MODEM) {
+	if ((port & HSO_PORT_MASK) == HSO_PORT_MODEM) {
 		num_urbs = 2;
 		serial->tiocmget = kzalloc(sizeof(struct hso_tiocmget),
 					   GFP_KERNEL);



-- 
best regards,
D.J. Barrow

Linux Kernel Developer
Option NV, Gaston Geenslaan 14, 3001 Leuven, Belgium
 
T: +32 16 311 621
F: +32 16 207 164
M: +32 4xx xxx xxx
d.barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org
www.option.com

Disclaimer:
http://www.option.com/company/disclaimer.shtml
 RPR Leuven 0429.375.448

--------------040706000202040603090502
Content-Type: text/x-diff;
 name="tty-hso-modem.fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tty-hso-modem.fix.patch"

Fixed incorrect check for the modem port, this prevents
crashes caused by issueing a tiocmget_submit_urb
on endpoints which don't exist for non modem devices. 
Signed-off-by: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
---
Index: linux-2.6.28-rc7.alan/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.28-rc7.alan.orig/drivers/net/usb/hso.c	2008-12-08 15:26:00.000000000 +0100
+++ linux-2.6.28-rc7.alan/drivers/net/usb/hso.c	2008-12-08 15:28:10.000000000 +0100
@@ -2659,7 +2659,7 @@
 	serial->parent = hso_dev;
 	hso_dev->port_data.dev_serial = serial;
 
-	if (port & HSO_PORT_MODEM) {
+	if ((port & HSO_PORT_MASK) == HSO_PORT_MODEM) {
 		num_urbs = 2;
 		serial->tiocmget = kzalloc(sizeof(struct hso_tiocmget),
 					   GFP_KERNEL);

--------------040706000202040603090502--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
