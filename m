From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Tulip interrupt uses non IRQ safe spinlock
Date: Fri, 27 May 2005 22:24:03 -0400
Message-ID: <4297D643.5020407@pobox.com>
References: <E1DRFqC-00028H-Qi@tigger>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262131AbVE1CYM@vger.kernel.org>
To: Mark Broadbent <markb@wetlettuce.com>
In-Reply-To: <E1DRFqC-00028H-Qi@tigger>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Broadbent wrote:
> The interrupt handling code in the tulip network driver appears to use a non 
> IRQ safe spinlock in an interrupt context.  The following patch should correct 
> this.
> 
> Signed-off-by: Mark Broadbent <markb@wetlettuce.com>
> 
> Index: linux-2.6.11/drivers/net/tulip/interrupt.c
> ===================================================================
> --- linux-2.6.11.orig/drivers/net/tulip/interrupt.c	2005-03-07 18:11:23.000000000 +0000
> +++ linux-2.6.11/drivers/net/tulip/interrupt.c	2005-04-28 16:16:23.000000000 +0100
> @@ -567,8 +567,9 @@
>  
>  		if (csr5 & (TxNoBuf | TxDied | TxIntr | TimerInt)) {
>  			unsigned int dirty_tx;
> +			unsigned long flags;
>  
> -			spin_lock(&tp->lock);
> +			spin_lock_irqsave(&tp->lock, flags);
>  
>  			for (dirty_tx = tp->dirty_tx; tp->cur_tx - dirty_tx > 0;
>  				 dirty_tx++) {
> @@ -640,7 +641,7 @@
>  						   dev->name, csr5, ioread32(ioaddr + CSR6), tp->csr6);
>  				tulip_restart_rxtx(tp);
>  			}
> -			spin_unlock(&tp->lock);
> +			spin_unlock_irqrestore(&tp->lock, flags);

It's already inside the interrupt handler, so this patch is not needed.

	Jeff
