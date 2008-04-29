From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] cxgb3: Use CAP_SYS_RAWIO for firmware
Date: Tue, 29 Apr 2008 14:29:30 +0100
Message-ID: <20080429142930.0181f078@core>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:51462 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752314AbYD2Ngz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 09:36:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise theoretically at least

	CAP_NET_ADMIN
	Reload new firmware
	Wait..
	Firmware patches kernel

So it should be CAY_SYS_RAWIO - not that I suspect this is in fact a
credible attack vector!

Signed-off-by: Alan Cox <alan@redhat.com>

diff -u --new-file --recursive --exclude-from /usr/src/exclude linux.vanilla-2.6.25-mm1/drivers/net/cxgb3/cxgb3_main.c linux-2.6.25-mm1/drivers/net/cxgb3/cxgb3_main.c
--- linux.vanilla-2.6.25-mm1/drivers/net/cxgb3/cxgb3_main.c	2008-04-28 11:36:42.000000000 +0100
+++ linux-2.6.25-mm1/drivers/net/cxgb3/cxgb3_main.c	2008-04-18 17:14:44.000000000 +0100
@@ -1894,11 +1894,11 @@
 		u8 *fw_data;
 		struct ch_mem_range t;
 
-		if (!capable(CAP_NET_ADMIN))
+		if (!capable(CAP_SYS_RAWIO))
 			return -EPERM;
 		if (copy_from_user(&t, useraddr, sizeof(t)))
 			return -EFAULT;
-
+		/* Check t.len sanity ? */
 		fw_data = kmalloc(t.len, GFP_KERNEL);
 		if (!fw_data)
 			return -ENOMEM;
