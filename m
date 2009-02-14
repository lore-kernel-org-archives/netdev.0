From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 34/43] drivers/net/usb: fix sparse warnings: Should it be
	static?
Date: Sat, 14 Feb 2009 22:47:47 +0100
Message-ID: <20090214214738.24377.82100.stgit@vmbox.hanneseder.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f167.google.com ([209.85.218.167]:33361 "EHLO
	mail-bw0-f167.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755193AbZBNVrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 16:47:53 -0500
In-Reply-To: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: Make symbols static.

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
index e6d62fe..a074c16 100644
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
@@ -1464,9 +1464,9 @@ static int hso_serial_chars_in_buffer(struct tty_struct *tty)
 
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
index 5b0b964..3e6155a 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -58,7 +58,7 @@ struct usb_context {
 	struct usbnet *dev;
 };
 
-int turbo_mode = true;
+static int turbo_mode = true;
 module_param(turbo_mode, bool, 0644);
 MODULE_PARM_DESC(turbo_mode, "Enable multiple frames per Rx transaction");
 

