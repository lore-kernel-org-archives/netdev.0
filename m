From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH 09/10] pxa: make zylonite to use the new smc91x platform
 data
Date: Thu, 26 Jun 2008 20:04:03 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0806262003510.2979@xanadu.home>
References: <1214300867-15495-10-git-send-email-eric.y.miao@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	linux-netdev <netdev@vger.kernel.org>,
	Magnus Damm <magnus.damm@gmail.com>,
	Eric Miao <eric.miao@marvell.com>
To: Eric Miao <eric.y.miao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:27404 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758513AbYF0AEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 20:04:04 -0400
Received: from xanadu.home ([66.131.194.97]) by VL-MO-MR004.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0K33001DWHIRVVF0@VL-MO-MR004.ip.videotron.ca> for
 netdev@vger.kernel.org; Thu, 26 Jun 2008 20:04:04 -0400 (EDT)
In-reply-to: <1214300867-15495-10-git-send-email-eric.y.miao@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Jun 2008, Eric Miao wrote:

> From: Eric Miao <eric.miao@marvell.com>
> 
> Signed-off-by: Eric Miao <eric.miao@marvell.com>

Acked-by: Nicolas Pitre <nico@cam.org>

> ---
>  arch/arm/mach-pxa/zylonite.c |    9 +++++++++
>  drivers/net/smc91x.h         |   19 ++-----------------
>  2 files changed, 11 insertions(+), 17 deletions(-)
> 
> diff --git a/arch/arm/mach-pxa/zylonite.c b/arch/arm/mach-pxa/zylonite.c
> index 4a4711d..8fca6d8 100644
> --- a/arch/arm/mach-pxa/zylonite.c
> +++ b/arch/arm/mach-pxa/zylonite.c
> @@ -19,6 +19,7 @@
>  #include <linux/init.h>
>  #include <linux/platform_device.h>
>  #include <linux/pwm_backlight.h>
> +#include <linux/smc91x.h>
>  
>  #include <asm/mach-types.h>
>  #include <asm/mach/arch.h>
> @@ -59,11 +60,19 @@ static struct resource smc91x_resources[] = {
>  	}
>  };
>  
> +static struct smc91x_platdata zylonite_smc91x_info = {
> +	.flags	= SMC91X_USE_8BIT | SMC91X_USE_16BIT |
> +		  SMC91X_NOWAIT | SMC91X_USE_DMA,
> +};
> +
>  static struct platform_device smc91x_device = {
>  	.name		= "smc91x",
>  	.id		= 0,
>  	.num_resources	= ARRAY_SIZE(smc91x_resources),
>  	.resource	= smc91x_resources,
> +	.dev		= {
> +		.platform_data = &zylonite_smc91x_info,
> +	},
>  };
>  
>  #if defined(CONFIG_LEDS_GPIO) || defined(CONFIG_LEDS_GPIO_MODULE)
> diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
> index 3d03284..d55739c 100644
> --- a/drivers/net/smc91x.h
> +++ b/drivers/net/smc91x.h
> @@ -41,7 +41,8 @@
>   */
>  
>  #if defined(CONFIG_ARCH_LUBBOCK) ||\
> -    defined(CONFIG_MACH_MAINSTONE)
> +    defined(CONFIG_MACH_MAINSTONE) ||\
> +    defined(CONFIG_MACH_ZYLONITE)
>  
>  #include <asm/mach-types.h>
>  
> @@ -249,22 +250,6 @@ SMC_outw(u16 val, void __iomem *ioaddr, int reg)
>  	}
>  }
>  
> -#elif defined(CONFIG_MACH_ZYLONITE)
> -
> -#define SMC_CAN_USE_8BIT        1
> -#define SMC_CAN_USE_16BIT       1
> -#define SMC_CAN_USE_32BIT       0
> -#define SMC_IO_SHIFT            0
> -#define SMC_NOWAIT              1
> -#define SMC_USE_PXA_DMA		1
> -#define SMC_inb(a, r)           readb((a) + (r))
> -#define SMC_inw(a, r)           readw((a) + (r))
> -#define SMC_insw(a, r, p, l)    insw((a) + (r), p, l)
> -#define SMC_outsw(a, r, p, l)   outsw((a) + (r), p, l)
> -#define SMC_outb(v, a, r)       writeb(v, (a) + (r))
> -#define SMC_outw(v, a, r)       writew(v, (a) + (r))
> -#define SMC_IRQ_FLAGS		(-1)	/* from resource */
> -
>  #elif	defined(CONFIG_ARCH_OMAP)
>  
>  /* We can only do 16-bit reads and writes in the static memory space. */
> -- 
> 1.5.4.3
> 


Nicolas
