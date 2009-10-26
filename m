From: Daniel Silverstone <dsilvers@simtec.co.uk>
Subject: Re: [PATCH]NET/KS8695: add support NAPI for Rx
Date: Mon, 26 Oct 2009 16:27:21 +0000
Message-ID: <20091026162721.GD9480@digital-scurf.org>
References: <1256572828.2148.5.camel@myhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Vincent Sanders <vince@simtec.co.uk>,
	Ben Dooks <ben@simtec.co.uk>
To: "Figo.zhang" <figo1802@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from flounder.pepperfish.net ([87.237.62.181]:46085 "EHLO
	flounder.pepperfish.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752347AbZJZQqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 12:46:55 -0400
Content-Disposition: inline
In-Reply-To: <1256572828.2148.5.camel@myhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 27, 2009 at 12:00:28AM +0800, Figo.zhang wrote:
> +#ifdef KS8695NET_NAPI
> +static irqreturn_t
> +ks8695_rx_irq(int irq, void *dev_id)

This routine lacks its documentation comment.  This driver is fully documented
in order to serve as a good example for others.  Indeed this lack of
documentation comments continues through your patch, I won't bring up each
instance, instead trusting you to go back over your patch and sort them out.

> +	status = __raw_readl(KS8695_IRQ_VA + KS8695_INTST);
[snip]
> +	__raw_writel(status | mask_bit , KS8695_IRQ_VA + KS8695_INTST);
[snip]
> +			__raw_writel(status , KS8695_IRQ_VA + KS8695_INTEN);
[snip]
> +	unsigned long isr = __raw_readl(KS8695_IRQ_VA + KS8695_INTEN);
[snip]
> +		__raw_writel(isr | mask_bit, KS8695_IRQ_VA + KS8695_INTEN);

Please don't use __raw_readl or __raw_writel.  This driver was nice and clean,
don't ruin it.

Also, as an aside, you seem to add a spinlock (rx_lock) which afaict is only
used by NAPI related routines, and yet you include it regardless of NAPI being
enabled or not.  Did I misread your patch, or is this an oversight?

Regards,

Daniel.

-- 
Daniel Silverstone                              http://www.simtec.co.uk/

