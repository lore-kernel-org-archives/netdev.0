From: akpm@osdl.org
Subject: [patch 4/5] bluetooth: small cleanups
Date: Tue, 19 Sep 2006 18:08:50 -0700
Message-ID: <200609200108.k8K18or0011722@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, pavel@suse.cz,
	marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:62352 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750818AbWITBJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 21:09:04 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Machek <pavel@suse.cz>

This cleans up bluetooth a bit, no code changes.

Signed-off-by: Pavel Machek <pavel@suse.cz>
Cc: Marcel Holtmann <marcel@holtmann.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/bluetooth/hci_ldisc.c |   13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff -puN drivers/bluetooth/hci_ldisc.c~bluetooth-small-cleanups drivers/bluetooth/hci_ldisc.c
--- a/drivers/bluetooth/hci_ldisc.c~bluetooth-small-cleanups
+++ a/drivers/bluetooth/hci_ldisc.c
@@ -241,15 +241,11 @@ static int hci_uart_send_frame(struct sk
 
 static void hci_uart_destruct(struct hci_dev *hdev)
 {
-	struct hci_uart *hu;
-
 	if (!hdev)
 		return;
 
 	BT_DBG("%s", hdev->name);
-
-	hu = (struct hci_uart *) hdev->driver_data;
-	kfree(hu);
+	kfree(hdev->driver_data);
 }
 
 /* ------ LDISC part ------ */
@@ -272,7 +268,7 @@ static int hci_uart_tty_open(struct tty_
 		return -EEXIST;
 
 	if (!(hu = kzalloc(sizeof(struct hci_uart), GFP_KERNEL))) {
-		BT_ERR("Can't allocate controll structure");
+		BT_ERR("Can't allocate control structure");
 		return -ENFILE;
 	}
 
@@ -360,7 +356,7 @@ static void hci_uart_tty_wakeup(struct t
  *     
  * Return Value:    None
  */
-static void hci_uart_tty_receive(struct tty_struct *tty, const __u8 *data, char *flags, int count)
+static void hci_uart_tty_receive(struct tty_struct *tty, const u8 *data, char *flags, int count)
 {
 	struct hci_uart *hu = (void *)tty->disc_data;
 
@@ -375,7 +371,8 @@ static void hci_uart_tty_receive(struct 
 	hu->hdev->stat.byte_rx += count;
 	spin_unlock(&hu->rx_lock);
 
-	if (test_and_clear_bit(TTY_THROTTLED,&tty->flags) && tty->driver->unthrottle)
+	if (test_and_clear_bit(TTY_THROTTLED, &tty->flags) &&
+			tty->driver->unthrottle)
 		tty->driver->unthrottle(tty);
 }
 
_
