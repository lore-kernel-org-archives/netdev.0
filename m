From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH 07/10] pxa: make lubbock to use new smc91x platform data
Date: Thu, 26 Jun 2008 20:02:21 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0806262002020.2979@xanadu.home>
References: <1214300867-15495-8-git-send-email-eric.y.miao@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	linux-netdev <netdev@vger.kernel.org>,
	Magnus Damm <magnus.damm@gmail.com>,
	Eric Miao <eric.miao@marvell.com>
To: Eric Miao <eric.y.miao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:35209 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754304AbYF0ACX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 20:02:23 -0400
Received: from xanadu.home ([66.131.194.97]) by VL-MO-MR004.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0K3300C56HFXQX40@VL-MO-MR004.ip.videotron.ca> for
 netdev@vger.kernel.org; Thu, 26 Jun 2008 20:02:22 -0400 (EDT)
In-reply-to: <1214300867-15495-8-git-send-email-eric.y.miao@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Jun 2008, Eric Miao wrote:

> From: Eric Miao <eric.miao@marvell.com>
> 
> Signed-off-by: Eric Miao <eric.miao@marvell.com>

Acked-by: Nicolas Pitre <nico@cam.org>

> ---
>  arch/arm/mach-pxa/lubbock.c |    8 ++++++++
>  drivers/net/smc91x.h        |    3 +--
>  2 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm/mach-pxa/lubbock.c b/arch/arm/mach-pxa/lubbock.c
> index 429e197..423c883 100644
> --- a/arch/arm/mach-pxa/lubbock.c
> +++ b/arch/arm/mach-pxa/lubbock.c
> @@ -21,6 +21,7 @@
>  #include <linux/interrupt.h>
>  #include <linux/mtd/mtd.h>
>  #include <linux/mtd/partitions.h>
> +#include <linux/smc91x.h>
>  
>  #include <linux/spi/spi.h>
>  #include <linux/spi/ads7846.h>
> @@ -335,11 +336,18 @@ static struct resource smc91x_resources[] = {
>  	},
>  };
>  
> +static struct smc91x_platdata lubbock_smc91x_info = {
> +	.flags	= SMC91X_USE_16BIT | SMC91X_NOWAIT | SMC91X_IO_SHIFT_2,
> +};
> +
>  static struct platform_device smc91x_device = {
>  	.name		= "smc91x",
>  	.id		= -1,
>  	.num_resources	= ARRAY_SIZE(smc91x_resources),
>  	.resource	= smc91x_resources,
> +	.dev		= {
> +		.platform_data = &lubbock_smc91x_info,
> +	},
>  };
>  
>  static struct resource flash_resources[] = {
> diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
> index 208dfc8..95ee9ed 100644
> --- a/drivers/net/smc91x.h
> +++ b/drivers/net/smc91x.h
> @@ -48,8 +48,7 @@
>  #define SMC_CAN_USE_32BIT	0
>  #define SMC_NOWAIT		1
>  
> -/* The first two address lines aren't connected... */
> -#define SMC_IO_SHIFT		2
> +#define SMC_IO_SHIFT		smc_io_shift
>  
>  #define SMC_inw(a, r)		readw((a) + (r))
>  #define SMC_outw(v, a, r)	writew(v, (a) + (r))
> -- 
> 1.5.4.3
> 


Nicolas
