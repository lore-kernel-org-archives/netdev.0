From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 19/27] drivers/net/usb: fix sparse warnings: make symbols
	static
Date: Mon, 22 Dec 2008 20:17:46 +0100
Message-ID: <20081222191745.11807.75548.stgit@vmbox.hanneseder.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:50184 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755504AbYLVTRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 14:17:51 -0500
In-Reply-To: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warnings:

  drivers/net/usb/hso.c:1249:6: warning: symbol 'hso_unthrottle_tasklet' was not declared. Should it be static?
  drivers/net/usb/hso.c:1268:6: warning: symbol 'hso_unthrottle_workfunc' was not declared. Should it be static?
  drivers/net/usb/hso.c:1466:5: warning: symbol 'tiocmget_submit_urb' was not declared. Should it be static?
  drivers/net/usb/smsc95xx.c:62:5: warning: symbol 'turbo_mode' was not declared. Should it be static?

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/usb/hso.c      |   10 +++++-----
 drivers/net/usb/smsc95xx.c |    2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 2d41a10..1a09288 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -1246,7 +1246,7 @@ static void hso_std_serial_read_bulk_callback(struct urb *urb)
  * This needs to be a tasklet otherwise we will
  * end up recursively calling this function.
  */
-void hso_unthrottle_tasklet(struct hso_serial *serial)
+static void hso_unthrottle_tasklet(struct hso_serial *serial)
 {
 	unsigned long flags;
 
@@ -1265,7 +1265,7 @@ static	void hso_unthrottle(struct tty_struct *tty)
 	tasklet_hi_schedule(&serial->unthrottle_tasklet);
 }
 
-void hso_unthrottle_workfunc(struct work_struct *work)
+static void hso_unthrottle_workfunc(struct work_struct *work)
 {
 	struct hso_serial *serial =
 	    container_of(work, struct hso_serial,
@@ -1463,9 +1463,9 @@ static int hso_serial_chars_in_buffer(struct tty_struct *tty)
 
 	return chars;
 }
-int tiocmget_submit_urb(struct hso_serial *serial,
-			struct hso_tiocmget  *tiocmget,
-			struct usb_device *usb)
+static int tiocmget_submit_urb(struct hso_serial *serial,
+			       struct hso_tiocmget *tiocmget,
+			       struct usb_device *usb)
 {
 	int result;
 
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index fed22ff..111a365 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -59,7 +59,7 @@ struct usb_context {
 	struct usbnet *dev;
 };
 
-int turbo_mode = true;
+static int turbo_mode = true;
 module_param(turbo_mode, bool, 0644);
 MODULE_PARM_DESC(turbo_mode, "Enable multiple frames per Rx transaction");
 

