From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] hso driver fix for big endian machines.
Date: Mon, 12 Jan 2009 15:59:10 +0100
Message-ID: <496B5ABE.2060406@option.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090306060305070801020409"
To: Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Paul Hardwick <P.Hardwick-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090306060305070801020409
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi there,
This patch is against 2.6.29-rc1 I hope it'll apply to other trees if neccessary.
Filip Aben says this fix is neccessary for big endian machines.

If anybody has one & a hso device & a big endian machine I'd greatly appreciate if you tell me if this
patch works.


A patch needed to make the hso driver work on big endian machines.
Signed-off-by: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
---
Index: linux-2.6/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.orig/drivers/net/usb/hso.c	2009-01-12 15:49:57.000000000 +0100
+++ linux-2.6/drivers/net/usb/hso.c	2009-01-12 15:50:33.000000000 +0100
@@ -1792,8 +1792,8 @@
 
 	/* initialize */
 	ctrl_req->wValue = 0;
-	ctrl_req->wIndex = hso_port_to_mux(port);
-	ctrl_req->wLength = size;
+	ctrl_req->wIndex = cpu_to_le16(hso_port_to_mux(port));
+	ctrl_req->wLength = cpu_to_le16(size);
 
 	if (type == USB_CDC_GET_ENCAPSULATED_RESPONSE) {
 		/* Reading command */

-- 
best regards,
D.J. Barrow

Linux Kernel Developer
Option NV, Gaston Geenslaan 14, 3001 Leuven, Belgium
 
T: +32 16 311 621
F: +32 16 207 164
d.barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org
www.option.com

Disclaimer:
http://www.option.com/company/disclaimer.shtml

--------------090306060305070801020409
Content-Type: text/x-diff;
 name="hso_big_endian.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_big_endian.patch"

A patch needed to make the hso driver work on big endian machines.
Signed-off-by: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
---
Index: linux-2.6/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.orig/drivers/net/usb/hso.c	2009-01-12 15:49:57.000000000 +0100
+++ linux-2.6/drivers/net/usb/hso.c	2009-01-12 15:50:33.000000000 +0100
@@ -1792,8 +1792,8 @@
 
 	/* initialize */
 	ctrl_req->wValue = 0;
-	ctrl_req->wIndex = hso_port_to_mux(port);
-	ctrl_req->wLength = size;
+	ctrl_req->wIndex = cpu_to_le16(hso_port_to_mux(port));
+	ctrl_req->wLength = cpu_to_le16(size);
 
 	if (type == USB_CDC_GET_ENCAPSULATED_RESPONSE) {
 		/* Reading command */

--------------090306060305070801020409--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
