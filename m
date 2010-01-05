From: Jan Dumon <j.dumon@option.com>
Subject: [PATCH 5/6] hso: Fix for 5 sec timeouts with v2.x firmware
Date: Tue, 5 Jan 2010 15:52:42 +0100
Message-ID: <20100105145242.GE19825@raptor>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.option.com ([81.246.70.163]:55545 "EHLO
	mailer2.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754200Ab0AEO4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 09:56:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Dumon <j.dumon@option.com>

Don't send flow control settings to any port other than the modem port.
Older firmware ignored this request but did sent a reply. Newer firmware just
ignores it without reply and causes a 5 second timeout every time a port
(except for the modem port) is opened or if tiocm settings are changed.

Signed-off-by: Jan Dumon <j.dumon@option.com>

--- linux-2.6.orig/drivers/net/usb/hso.c
+++ linux-2.6/drivers/net/usb/hso.c
@@ -1723,6 +1723,10 @@ static int hso_serial_tiocmset(struct tt
 		D1("no tty structures");
 		return -EINVAL;
 	}
+
+	if ((serial->parent->port_spec & HSO_PORT_MASK) != HSO_PORT_MODEM)
+		return -EINVAL;
+
 	if_num = serial->parent->interface->altsetting->desc.bInterfaceNumber;
 
 	spin_lock_irqsave(&serial->serial_lock, flags);
