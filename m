From: Greg KH <greg@kroah.com>
Subject: [01/04] hso: fix oops in read/write callbacks
Date: Fri, 8 Aug 2008 12:01:11 -0700
Message-ID: <20080808190111.GB2953@kroah.com>
References: <20080808190023.GA2953@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Jari Tenhunen <jari.tenhunen@iki.fi>,
	Olivier Blin <blino@mandriva.com>,
	Andrew Bird <ajb@spheresystems.co.uk>,
	Paul Rolland <rol@witbe.net>,
	Arjan van de Ven <arjan@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:36328 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754460AbYHHTFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 15:05:19 -0400
Content-Disposition: inline
In-Reply-To: <20080808190023.GA2953@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Olivier Blin <blino@mandriva.com>

The tty may be closed already when the read/write callbacks are called.
This patch checks that the ttys still exist before waking them up.

Signed-off-by: Olivier Blin <blino@mandriva.com>
Acked-by: Alan Cox <alan@redhat.com>
Cc: Jari Tenhunen <jari.tenhunen@iki.fi>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/net/usb/hso.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -1467,7 +1467,8 @@ static void hso_std_serial_write_bulk_ca
 		return;
 	}
 	hso_put_activity(serial->parent);
-	tty_wakeup(serial->tty);
+	if (serial->tty)
+		tty_wakeup(serial->tty);
 	hso_kick_transmit(serial);
 
 	D1(" ");
@@ -1538,7 +1539,8 @@ static void ctrl_callback(struct urb *ur
 			clear_bit(HSO_SERIAL_FLAG_RX_SENT, &serial->flags);
 	} else {
 		hso_put_activity(serial->parent);
-		tty_wakeup(serial->tty);
+		if (serial->tty)
+			tty_wakeup(serial->tty);
 		/* response to a write command */
 		hso_kick_transmit(serial);
 	}
