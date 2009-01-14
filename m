From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 02/02] hso remove dead workfunc code
Date: Wed, 14 Jan 2009 12:25:59 +0100
Message-ID: <496DCBC7.5010302@option.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010808000103090802020508"
To: Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010808000103090802020508
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Sorry I left this rubbish lying around 

Index: linux-2.6/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.orig/drivers/net/usb/hso.c	2009-01-14 12:02:56.000000000 +0100
+++ linux-2.6/drivers/net/usb/hso.c	2009-01-14 12:03:11.000000000 +0100
@@ -270,7 +270,6 @@
 	u16  curr_rx_urb_offset;
 	u8   rx_urb_filled[MAX_RX_URBS];
 	struct tasklet_struct unthrottle_tasklet;
-	struct work_struct    retry_unthrottle_workqueue;
 };
 
 struct hso_device {
@@ -1264,14 +1263,6 @@
 	tasklet_hi_schedule(&serial->unthrottle_tasklet);
 }
 
-void hso_unthrottle_workfunc(struct work_struct *work)
-{
-	struct hso_serial *serial =
-	    container_of(work, struct hso_serial,
-			 retry_unthrottle_workqueue);
-	hso_unthrottle_tasklet(serial);
-}
-
 /* open the requested serial port */
 static int hso_serial_open(struct tty_struct *tty, struct file *filp)
 {
@@ -1310,8 +1301,6 @@
 		tasklet_init(&serial->unthrottle_tasklet,
 			     (void (*)(unsigned long))hso_unthrottle_tasklet,
 			     (unsigned long)serial);
-		INIT_WORK(&serial->retry_unthrottle_workqueue,
-			  hso_unthrottle_workfunc);
 		result = hso_start_serial_device(serial->parent, GFP_KERNEL);
 		if (result) {
 			hso_stop_serial_device(serial->parent);
@@ -1367,7 +1356,6 @@
 		if (!usb_gone)
 			hso_stop_serial_device(serial->parent);
 		tasklet_kill(&serial->unthrottle_tasklet);
-		cancel_work_sync(&serial->retry_unthrottle_workqueue);
 	}
 	if (!usb_gone)
 		usb_autopm_put_interface(serial->parent->interface);

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

--------------010808000103090802020508
Content-Type: text/x-diff;
 name="hso_remove_obselete_workfunc.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_remove_obselete_workfunc.patch"

Index: linux-2.6/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.orig/drivers/net/usb/hso.c	2009-01-14 12:02:56.000000000 +0100
+++ linux-2.6/drivers/net/usb/hso.c	2009-01-14 12:03:11.000000000 +0100
@@ -270,7 +270,6 @@
 	u16  curr_rx_urb_offset;
 	u8   rx_urb_filled[MAX_RX_URBS];
 	struct tasklet_struct unthrottle_tasklet;
-	struct work_struct    retry_unthrottle_workqueue;
 };
 
 struct hso_device {
@@ -1264,14 +1263,6 @@
 	tasklet_hi_schedule(&serial->unthrottle_tasklet);
 }
 
-void hso_unthrottle_workfunc(struct work_struct *work)
-{
-	struct hso_serial *serial =
-	    container_of(work, struct hso_serial,
-			 retry_unthrottle_workqueue);
-	hso_unthrottle_tasklet(serial);
-}
--------------010808000103090802020508--
