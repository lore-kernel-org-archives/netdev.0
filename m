From: f.aben@option.com
Subject: [PATCH] hso: remove setting of low_latency flag
Date: Fri, 11 Jun 2010 11:17:06 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1006111100250.6812@filip-linux>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	j.dumon@option.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.option.com ([81.246.70.163]:3924 "EHLO
	mailer2.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755787Ab0FKJRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 05:17:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch removes the setting of the low_latency flag. 
tty_flip_buffer_push() is occasionally being called in irq context, which 
causes a hang if the low_latency flag is set.
Removing the low_latency flag only seems to impact the flush to ldisc, 
which will now be put on a workqueue.

Signed-off-by: Filip Aben <f.aben@option.com>

---

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 0a3c41f..4dd2351 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -1334,7 +1334,6 @@ static int hso_serial_open(struct tty_struct *tty, struct file *filp)
 	/* check for port already opened, if not set the termios */
 	serial->open_count++;
 	if (serial->open_count == 1) {
-		tty->low_latency = 1;
 		serial->rx_state = RX_IDLE;
 		/* Force default termio settings */
 		_hso_serial_set_termios(tty, NULL);
