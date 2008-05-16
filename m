From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Subject: Re: [PATCH -next] 3c515: fix using pnp_get_resource when CONFIG_ISAPNP=n
Date: Fri, 16 May 2008 12:15:05 -0600
Message-ID: <200805161215.06046.bjorn.helgaas@hp.com>
References: <20080516103524.0b00ffb6.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, jgarzik <jgarzik@pobox.com>,
	linux-next@vger.kernel.org, akpm <akpm@linux-foundation.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:20006 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751824AbYEPSPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 14:15:05 -0400
In-Reply-To: <20080516103524.0b00ffb6.randy.dunlap@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 16 May 2008 11:35:24 am Randy Dunlap wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> 3c515.c uses pnp_irq(), which calls pnp_get_resource(),
> which is not defined when CONFIG_PNP=n, so in that case,
> get the IRQ from a hardware register.
> 
> 3c515.c:(.text+0x3adc0): undefined reference to `pnp_get_resource'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Hmm, wonder why my allyesconfig didn't catch this one.
I prefer CONFIG_PNP to __ISAPNP__ in general, but I see
you're just following the other tests in the same file.

Thanks!

Acked-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

> ---
>  drivers/net/3c515.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> --- next-20080516.orig/drivers/net/3c515.c
> +++ next-20080516/drivers/net/3c515.c
> @@ -572,12 +572,16 @@ static int corkscrew_setup(struct net_de
>  	int irq;
>  	DECLARE_MAC_BUF(mac);
>  
> +#ifdef __ISAPNP__
>  	if (idev) {
>  		irq = pnp_irq(idev, 0);
>  		vp->dev = &idev->dev;
>  	} else {
>  		irq = inw(ioaddr + 0x2002) & 15;
>  	}
> +#else
> +	irq = inw(ioaddr + 0x2002) & 15;
> +#endif
>  
>  	dev->base_addr = ioaddr;
>  	dev->irq = irq;
> 


