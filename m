From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] Disable polling in rtl8169_suspend() to prevent race
	with rtl8169_interrupt()
Date: Tue, 16 Oct 2007 23:04:12 +0200
Message-ID: <20071016210412.GB8049@electric-eye.fr.zoreil.com>
References: <200710161846.52509.fzu@wemgehoertderstaat.de> <200710162127.52228.fzu@wemgehoertderstaat.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Karsten Wiese <fzu@wemgehoertderstaat.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:33643 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935918AbXJPVHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 17:07:38 -0400
Content-Disposition: inline
In-Reply-To: <200710162127.52228.fzu@wemgehoertderstaat.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Karsten Wiese <fzu@wemgehoertderstaat.de> :
[...]
> Forgot to say: patch is against 2.6.23. Stable material, if it gets an ACK.
> The BUG happens since months here, if not since I hibernate this pc.

Can you give the patch below a try too ?


diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 285b2b2..fcd79b7 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2424,6 +2424,7 @@ static void rtl8169_reset_task(struct work_struct *work)
 		rtl8169_init_ring_indexes(tp);
 		rtl_hw_start(dev);
 		netif_wake_queue(dev);
+		rtl8169_check_link_status(dev, tp, tp->mmio_addr);
 	} else {
 		if (net_ratelimit() && netif_msg_intr(tp)) {
 			printk(PFX KERN_EMERG "%s: Rx buffers shortage\n",
-- 
Ueimor
