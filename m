From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH v2] drivers/net/usb/hso.c: prevent reading uninitialized
 memory
Date: Wed, 15 Sep 2010 17:43:28 -0400
Message-ID: <1284587008.6275.95.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org, davem@davemloft.net, stable@kernel.org
To: j.dumon@option.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:59098 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755325Ab0IOVtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 17:49:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed formatting (tabs and line breaks).

The TIOCGICOUNT device ioctl allows unprivileged users to read
uninitialized stack memory, because the "reserved" member of the
serial_icounter_struct struct declared on the stack in hso_get_count()
is not altered or zeroed before being copied back to the user.  This
patch takes care of it.

Signed-off-by: Dan Rosenberg <dan.j.rosenberg@gmail.com>

--- linux-2.6.35.4.orig/drivers/net/usb/hso.c	2010-08-26 19:47:12.000000000 -0400
+++ linux-2.6.35.4/drivers/net/usb/hso.c	2010-09-14 21:26:18.477585183 -0400
@@ -1653,6 +1653,8 @@ static int hso_get_count(struct hso_seri
 	struct uart_icount cnow;
 	struct hso_tiocmget  *tiocmget = serial->tiocmget;
 
+	memset(&icount, 0, sizeof(struct serial_icounter_struct));
+
 	if (!tiocmget)
 		 return -ENOENT;
 	spin_lock_irq(&serial->serial_lock);






