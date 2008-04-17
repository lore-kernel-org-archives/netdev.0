From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] RESEND 8390: Split 8390 support into a pausing and a
 non pausing driver core
Date: Wed, 16 Apr 2008 20:46:25 -0400
Message-ID: <48069DE1.7080301@garzik.org>
References: <20080119155817.326ee5e0@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50604 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752669AbYDQAqf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 20:46:35 -0400
In-Reply-To: <20080119155817.326ee5e0@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alan Cox wrote:
> +++ linux-2.6.24-rc8-mm1/drivers/net/8390p.c	2008-01-19 15:00:41.000000000 +0000
> @@ -0,0 +1,66 @@
> +/* 8390 core for ISA devices needing bus delays */
> +
> +static const char version[] =
> +    "8390p.c:v1.10cvs 9/23/94 Donald Becker (becker@cesdis.gsfc.nasa.gov)\n";
> +
> +#define ei_inb(_p)	inb(_p)
> +#define ei_outb(_v,_p)	outb(_v,_p)
> +#define ei_inb_p(_p)	inb_p(_p)
> +#define ei_outb_p(_v,_p) outb_p(_v,_p)
> +
> +#include "lib8390.c"
> +
> +int eip_open(struct net_device *dev)
> +{
> +	return __ei_open(dev);
> +}
> +
> +int eip_close(struct net_device *dev)
> +{
> +	return __ei_close(dev);
> +}
> +
> +irqreturn_t eip_interrupt(int irq, void *dev_id)
> +{
> +	return __ei_interrupt(irq, dev_id);
> +}
> +
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +void eip_poll(struct net_device *dev)
> +{
> +	__ei_poll(dev);
> +}
> +#endif
> +
> +struct net_device *__alloc_eip_netdev(int size)
> +{
> +	return ____alloc_ei_netdev(size);
> +}
> +
> +void NS8390p_init(struct net_device *dev, int startp)
> +{
> +	return __NS8390_init(dev, startp);
> +}
> +
> +EXPORT_SYMBOL(eip_open);
> +EXPORT_SYMBOL(eip_close);
> +EXPORT_SYMBOL(eip_interrupt);
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +EXPORT_SYMBOL(eip_poll);
> +#endif
> +EXPORT_SYMBOL(NS8390p_init);
> +EXPORT_SYMBOL(__alloc_eip_netdev);
> +
> +#if defined(MODULE)
> +
> +int init_module(void)
> +{
> +	return 0;
> +}
> +
> +void cleanup_module(void)
> +{
> +}
> +
> +#endif /* MODULE */
> +MODULE_LICENSE("GPL");

Now that this has seen a bit of testing, and accumulated some fix 
patches in -mm, can I get a roll-up of all those into a single patch?

Looks OK to me.  My one minor comment is that I would think the 
init_module() would be superfluous?

	Jeff


