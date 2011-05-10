From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: slcan: fix ldisc->open retval
Date: Tue, 10 May 2011 08:09:05 +0200
Message-ID: <4DC8D681.8000602@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matvejchikov@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:8431 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751581Ab1EJGJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 02:09:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TTY layer expects 0 if the ldisc->open operation succeeded.

Reported-by: Matvejchikov Ilya <matvejchikov@gmail.com>
Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

---

diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
index b423965..1b49df6 100644
--- a/drivers/net/can/slcan.c
+++ b/drivers/net/can/slcan.c
@@ -583,7 +583,9 @@ static int slcan_open(struct tty_struct *tty)
 	/* Done.  We have linked the TTY line to a channel. */
 	rtnl_unlock();
 	tty->receive_room = 65536;	/* We don't flow control */
-	return sl->dev->base_addr;
+
+	/* TTY layer expects 0 on success */
+	return 0;
 
 err_free_chan:
 	sl->tty = NULL;

