From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: kernel: TD structure error TDindex=e
Date: Sun, 20 Jul 2008 18:08:12 +0200
Message-ID: <20080720160812.GA23652@electric-eye.fr.zoreil.com>
References: <48835302.1090708@xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Udo van den Heuvel <udovdh@xs4all.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40653 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757292AbYGTQIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 12:08:14 -0400
Content-Disposition: inline
In-Reply-To: <48835302.1090708@xs4all.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Udo van den Heuvel <udovdh@xs4all.nl> :
[...]
> 16:41:09 recorder kernel: TD structure error TDindex=e
> 
> This was on a VIA EN12000 board (with VIA Velocity Gbit ethernet,
> running 2.6.25.7) while doing a file transfer. The card was `down` after
> that.
[...]
> How can I avoid/fix/etc this situation ?

Can you apply the patch below to get some more information ?

May I assume that it does not count as a regression ?

Thanks in advance.

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 370ce30..57ee35b 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1743,7 +1743,8 @@ static void velocity_error(struct velocity_info *vptr, int status)
 	if (status & ISR_TXSTLI) {
 		struct mac_regs __iomem * regs = vptr->mac_regs;
 
-		printk(KERN_ERR "TD structure error TDindex=%hx\n", readw(&regs->TDIdx[0]));
+		printk(KERN_ERR "Tx process error TDIdx=0x%04x TXESR=0x%02x\n",
+		       readw(&regs->TDIdx[0]), readb(&regs->TXESR));
 		BYTE_REG_BITS_ON(TXESR_TDSTR, &regs->TXESR);
 		writew(TRDCSR_RUN, &regs->TDCSRClr);
 		netif_stop_queue(vptr->dev);
-- 
Ueimor
