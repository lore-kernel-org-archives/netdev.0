From: Peter Hurley <peter@hurleysoftware.com>
Subject: [PATCH v2 03/14] isdn: i4l: Remove ASYNC_CTS_FLOW
Date: Wed, 10 Sep 2014 15:06:25 -0400
Message-ID: <1410375996-4693-4-git-send-email-peter@hurleysoftware.com>
References: <1409693975-1028-1-git-send-email-peter@hurleysoftware.com>
 <1410375996-4693-1-git-send-email-peter@hurleysoftware.com>
Cc: Jiri Slaby <jslaby@suse.cz>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	linux-kernel@vger.kernel.org, linux-serial@vger.kernel.org,
	Peter Hurley <peter@hurleysoftware.com>,
	Karsten Keil <isdn@linux-pingi.de>, <netdev@vger.kernel.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410375996-4693-1-git-send-email-peter@hurleysoftware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ISDN4Linux always enables CTS flow control and does not use the
tty_port_cts_enabled() helper function; remove ASYNC_CTS_FLOW
state enable/disable.

cc: Karsten Keil <isdn@linux-pingi.de>
cc: <netdev@vger.kernel.org>
Signed-off-by: Peter Hurley <peter@hurleysoftware.com>
---
 drivers/isdn/i4l/isdn_tty.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_tty.c b/drivers/isdn/i4l/isdn_tty.c
index 3c5f249..bc91261 100644
--- a/drivers/isdn/i4l/isdn_tty.c
+++ b/drivers/isdn/i4l/isdn_tty.c
@@ -1043,11 +1043,6 @@ isdn_tty_change_speed(modem_info *info)
 	if (!(cflag & PARODD))
 		cval |= UART_LCR_EPAR;
 
-	/* CTS flow control flag and modem status interrupts */
-	if (cflag & CRTSCTS) {
-		port->flags |= ASYNC_CTS_FLOW;
-	} else
-		port->flags &= ~ASYNC_CTS_FLOW;
 	if (cflag & CLOCAL)
 		port->flags &= ~ASYNC_CHECK_CD;
 	else {
-- 
2.1.0
