From: akpm@osdl.org
Subject: [patch 04/17] ppp_async hang fix
Date: Thu, 01 Jun 2006 20:32:24 -0700
Message-ID: <200606020328.k523S5j2028814@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, xeb@mail.ru,
	paulus@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:63156 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751201AbWFBD2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2006 23:28:15 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: <xeb@mail.ru>

Adapted from  http://bugzilla.kernel.org/show_bug.cgi?id=6530

Reschedule the async Tx tasklet if the transmit queue was full.

Cc: Paul Mackerras <paulus@samba.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/ppp_async.c |    2 ++
 1 file changed, 2 insertions(+)

diff -puN drivers/net/ppp_async.c~ppp_async-hang-fix drivers/net/ppp_async.c
--- devel/drivers/net/ppp_async.c~ppp_async-hang-fix	2006-06-01 20:31:49.000000000 -0700
+++ devel-akpm/drivers/net/ppp_async.c	2006-06-01 20:31:49.000000000 -0700
@@ -516,6 +516,8 @@ static void ppp_async_process(unsigned l
 	/* try to push more stuff out */
 	if (test_bit(XMIT_WAKEUP, &ap->xmit_flags) && ppp_async_push(ap))
 		ppp_output_wakeup(&ap->chan);
+	else if (test_bit(XMIT_FULL, &ap->xmit_flags))
+		ppp_asynctty_wakeup(ap->tty);
 }
 
 /*
_
