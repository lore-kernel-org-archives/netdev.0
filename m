From: Daniel Silverstone <dsilvers@simtec.co.uk>
Subject: Re: [PATCH V2]NET/KS8695: add support NAPI for Rx
Date: Wed, 28 Oct 2009 12:06:44 +0000
Message-ID: <20091028120643.GA7883@digital-scurf.org>
References: <1256653422.2148.23.camel@myhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Ben Dooks <ben@simtec.co.uk>
To: "Figo.zhang" <figo1802@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from flounder.pepperfish.net ([87.237.62.181]:33013 "EHLO
	flounder.pepperfish.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753013AbZJ1MGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 08:06:43 -0400
Content-Disposition: inline
In-Reply-To: <1256653422.2148.23.camel@myhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 27, 2009 at 10:23:42PM +0800, Figo.zhang wrote:
> for wan, irq = 29; for lan ,irq = 16.
> so we can do this read the interrupt status:
> 
> unsigned long mask_bit = 1 << ksp->rx_irq;
> status = readl(KS8695_IRQ_VA + KS8695_INTST);

I hate that there's no proper IRQ functions for managing these, as Ben has
commented.  Although I can understand that writing such is beyond the scope of
this patch.

>  #define MODULENAME	"ks8695_ether"
>  #define MODULEVERSION	"1.01"

You still didn't update the module version.  This is a pity because you've
potentially radically changed behaviour and you definitely have radically
changed implementation.

> +	struct napi_struct	napi;
> +	spinlock_t rx_lock;

You have not added documentation for these fields in the structure's
documentation string.

> + *	Use NAPI to receive packets.

"Inform NAPI that packet reception needs to be scheduled." might be better.

> +static int ks8695_rx(struct net_device *ndev, int budget)

This routine lacks a documentation string. Please write one.

> -	/* Kick the RX DMA engine, in case it became suspended */
> -	ks8695_writereg(ksp, KS8695_DRSC, 0);

I can't see where you have moved this to.  Without it, sometimes the KS8695's
RX DMA engine will falter and packets won't be transferred properly.

> +static int ks8695_poll(struct napi_struct *napi, int budget)

This routine also lacks a documentation string.

> +	netif_napi_add(ndev, &ksp->napi, ks8695_poll, 64);

This '64' seems quite arbitrary.  Is it a standard default? Did you work it out
from something else?  Some explanation would be nice.


I see that Dave Miller has accepted your patch into net-next-2.6.  I'd like to
see the above fixed before that gets merged any further.

Regards,

Daniel.

-- 
Daniel Silverstone                              http://www.simtec.co.uk/

