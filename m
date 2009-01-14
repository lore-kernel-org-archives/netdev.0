From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] hso_spinlockfix.patch
Date: Wed, 14 Jan 2009 10:54:51 +0100
Message-ID: <496DB66B.4070306@option.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070309080903040600030603"
To: Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070309080903040600030603
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi,
This is a really important fix it fixes a consistent kernel deadlock
when the hso driver starts going. It's against 2.6.29-rc1, 2.6.29-rc6
worked fine.

This patch obviously wasn't tested & I neither I or Filip was subscribed to the tty mailing 
list to catch it.

Even with this patch the driver is still broken.
opening the serial port on the driver a second time causes a -EIO,
I've yet to figure out what but it is not returned from hso_serial_open
but a parent function.


This patch fixes a double grabbing of a spinlock all
functions which call put_rxbuf_data already have serial->serial_lock grabbed.
Signed-off-by: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Index: linux-2.6/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.orig/drivers/net/usb/hso.c	2009-01-13 17:39:15.000000000 +0100
+++ linux-2.6/drivers/net/usb/hso.c	2009-01-13 17:40:42.000000000 +0100
@@ -2043,9 +2043,7 @@
 		return -2;
 	}
 
-	spin_lock(&serial->serial_lock);
 	tty = tty_kref_get(serial->tty);
-	spin_unlock(&serial->serial_lock);
 
 	/* Push data to tty */
 	if (tty) {

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

--------------070309080903040600030603
Content-Type: text/x-diff;
 name="hso_spinlockfix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_spinlockfix.patch"

This patch fixes a double grabbing of a spinlock all
functions which call put_rxbuf_data already have serial->serial_lock grabbed.
Signed-off-by: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Index: linux-2.6/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.orig/drivers/net/usb/hso.c	2009-01-13 17:39:15.000000000 +0100
+++ linux-2.6/drivers/net/usb/hso.c	2009-01-13 17:40:42.000000000 +0100
@@ -2043,9 +2043,7 @@
 		return -2;
 	}
 
-	spin_lock(&serial->serial_lock);
 	tty = tty_kref_get(serial->tty);
-	spin_unlock(&serial->serial_lock);
 
 	/* Push data to tty */
 	if (tty) {

--------------070309080903040600030603--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
