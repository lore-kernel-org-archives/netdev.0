From: Martin Langer <martin-langer@gmx.de>
Subject: [PATCH] de2104x: wrong MAC address fix
Date: Mon, 13 Oct 2008 20:04:59 +0200
Message-ID: <20081013180459.GA3389@tuba>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:41383 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756715AbYJMSFG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2008 14:05:06 -0400
Received: from ml by tuba with local (Exim 4.50)
	id 1KpRmt-0000vG-6V
	for netdev@vger.kernel.org; Mon, 13 Oct 2008 20:04:59 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The de2104x returns sometimes a wrong MAC address. The wrong one is
like the original one, but it comes with an one byte shift. I found
this bug on an older alpha ev5 cpu. More details are available in Gentoo
bugreport #240718.

It seems the hardware is sometimes a little bit too slow for an
immediate access. This patch solves the problem by introducing a small
udelay.

Signed-off-by: Martin Langer <martin-langer@gmx.de>


--- drivers/net/tulip/de2104x.c_ORIGINAL	2008-10-10 00:13:53.000000000 +0200
+++ drivers/net/tulip/de2104x.c	2008-10-11 19:04:32.000000000 +0200
@@ -1689,6 +1689,7 @@
 	unsigned i;
 
 	dw32 (ROMCmd, 0);	/* Reset the pointer with a dummy write. */
+	udelay(5);
 
 	for (i = 0; i < 6; i++) {
 		int value, boguscnt = 100000;
