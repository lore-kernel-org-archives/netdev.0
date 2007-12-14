From: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Subject: [PATCH] [AX25] circular locking with AX25 connection timeout
Date: Fri, 14 Dec 2007 23:29:28 +0100
Message-ID: <476303C8.2060507@ccr.jussieu.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040008080001000104060504"
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postfix2-g20.free.fr ([212.27.60.43]:59407 "EHLO
	postfix2-g20.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756606AbXLNWxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 17:53:19 -0500
Received: from smtp5-g19.free.fr (smtp5-g19.free.fr [212.27.42.35])
	by postfix2-g20.free.fr (Postfix) with ESMTP id 66C14213452B
	for <netdev@vger.kernel.org>; Fri, 14 Dec 2007 21:52:30 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040008080001000104060504
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

This patch cancels a circular locking conflict that appeared with a 
timeout of an AX25 connection.

signed off by Jarek Poplawski

--------------040008080001000104060504
Content-Type: text/plain;
 name="rose-2.6.24-rc5.patch3"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rose-2.6.24-rc5.patch3"

--- linux-2.6.24-rc5/net/ax25/ax25_subr.c	2007-12-11 04:48:43.000000000 +0100
+++ b/net/ax25/ax25_subr.c	2007-12-14 14:30:02.000000000 +0100
@@ -279,6 +279,7 @@
 	ax25_link_failed(ax25, reason);
 
 	if (ax25->sk != NULL) {
+		local_bh_disable();
 		bh_lock_sock(ax25->sk);
 		ax25->sk->sk_state     = TCP_CLOSE;
 		ax25->sk->sk_err       = reason;
@@ -288,5 +289,6 @@
 			sock_set_flag(ax25->sk, SOCK_DEAD);
 		}
 		bh_unlock_sock(ax25->sk);
+		local_bh_enable(); 
 	}
 }

--------------040008080001000104060504--

