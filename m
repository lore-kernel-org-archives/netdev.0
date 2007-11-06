From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH] add support for smc91x ethernet interface on zylonite
Date: Mon, 05 Nov 2007 22:37:56 -0500 (EST)
Message-ID: <alpine.LFD.0.9999.0711052235121.21255@xanadu.home>
References: <f17812d70711051645p4d1a8e44mbc21413cc6ef12ba@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: eric miao <eric.y.miao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:52539 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754008AbXKFDh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 22:37:57 -0500
Received: from xanadu.home ([74.56.106.175]) by VL-MO-MR002.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0JR20077IFF8SJB0@VL-MO-MR002.ip.videotron.ca> for
 netdev@vger.kernel.org; Mon, 05 Nov 2007 22:37:56 -0500 (EST)
In-reply-to: <f17812d70711051645p4d1a8e44mbc21413cc6ef12ba@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 6 Nov 2007, eric miao wrote:

> >From 9363662844b6373ddf4265e7007eb29ff963a377 Mon Sep 17 00:00:00 2001
> From: eric miao <eric.miao@marvell.com>

According to the SOB line below, shouldn't this be:
From: Aleksey Makarov <amakarov@ru.mvista.com>
?

> Date: Tue, 30 Oct 2007 09:48:41 +0800
> Subject: [PATCH] add support for smc91x ethernet interface on zylonite
> 
> This patch adds LAN91C111 ethernet interface support for zylonite
> (a.k.a Marvell's PXA3xx Development Platform) with smc91x driver.
> 
> It would be better if a patch would support zylonite along with all
> other PXA boards with a single binary of smc91x driver, but it looks
> quite difficult for the moment, so ugly #ifdef is still used here.
> 
> Signed-off-by: Aleksey Makarov <amakarov@ru.mvista.com>
> Acked-by: eric miao <eric.miao@marvell.com>

Acked-by: Nicolas Pitre <nico@cam.org>

> ---
>  drivers/net/smc91x.h |   15 +++++++++++++++
>  1 files changed, 15 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
> index 729fd28..db34e1e 100644
> --- a/drivers/net/smc91x.h
> +++ b/drivers/net/smc91x.h
> @@ -224,6 +224,21 @@ SMC_outw(u16 val, void __iomem *ioaddr, int reg)
>  	}
>  }
> 
> +#elif defined(CONFIG_MACH_ZYLONITE)
> +
> +#define SMC_CAN_USE_8BIT        1
> +#define SMC_CAN_USE_16BIT       1
> +#define SMC_CAN_USE_32BIT       0
> +#define SMC_IO_SHIFT            0
> +#define SMC_NOWAIT              1
> +#define SMC_USE_PXA_DMA		1
> +#define SMC_inb(a, r)           readb((a) + (r))
> +#define SMC_inw(a, r)           readw((a) + (r))
> +#define SMC_insw(a, r, p, l)    insw((a) + (r), p, l)
> +#define SMC_outsw(a, r, p, l)   outsw((a) + (r), p, l)
> +#define SMC_outb(v, a, r)       writeb(v, (a) + (r))
> +#define SMC_outw(v, a, r)       writew(v, (a) + (r))
> +
>  #elif	defined(CONFIG_ARCH_OMAP)
> 
>  /* We can only do 16-bit reads and writes in the static memory space. */
> -- 
> 1.5.2.5.GIT
> 


Nicolas
