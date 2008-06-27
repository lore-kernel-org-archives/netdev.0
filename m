From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH 10/10] pxa: make littleton to use the new smc91x platform
 data
Date: Thu, 26 Jun 2008 20:04:32 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0806262004190.2979@xanadu.home>
References: <1214300867-15495-11-git-send-email-eric.y.miao@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	linux-netdev <netdev@vger.kernel.org>,
	Magnus Damm <magnus.damm@gmail.com>,
	Eric Miao <eric.miao@marvell.com>
To: Eric Miao <eric.y.miao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:21849 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754742AbYF0AEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 20:04:33 -0400
Received: from xanadu.home ([66.131.194.97]) by VL-MO-MR004.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0K33001G3HJKVVF0@VL-MO-MR004.ip.videotron.ca> for
 netdev@vger.kernel.org; Thu, 26 Jun 2008 20:04:32 -0400 (EDT)
In-reply-to: <1214300867-15495-11-git-send-email-eric.y.miao@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Jun 2008, Eric Miao wrote:

> From: Eric Miao <eric.miao@marvell.com>
> 
> Signed-off-by: Eric Miao <eric.miao@marvell.com>

Acked-by: Nicolas Pitre <nico@cam.org>

> ---
>  arch/arm/mach-pxa/littleton.c |    9 +++++++++
>  drivers/net/smc91x.h          |    3 ++-
>  2 files changed, 11 insertions(+), 1 deletions(-)
> 
> diff --git a/arch/arm/mach-pxa/littleton.c b/arch/arm/mach-pxa/littleton.c
> index 9a4f51d..dd759d0 100644
> --- a/arch/arm/mach-pxa/littleton.c
> +++ b/arch/arm/mach-pxa/littleton.c
> @@ -20,6 +20,7 @@
>  #include <linux/delay.h>
>  #include <linux/platform_device.h>
>  #include <linux/clk.h>
> +#include <linux/smc91x.h>
>  
>  #include <asm/types.h>
>  #include <asm/setup.h>
> @@ -106,11 +107,19 @@ static struct resource smc91x_resources[] = {
>  	}
>  };
>  
> +static struct smc91x_platdata littleton_smc91x_info = {
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
> +		.platform_data = &littleton_smc91x_info,
> +	},
>  };
>  
>  #if defined(CONFIG_FB_PXA) || defined(CONFIG_FB_PXA_MODULE)
> diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
> index d55739c..46ebac8 100644
> --- a/drivers/net/smc91x.h
> +++ b/drivers/net/smc91x.h
> @@ -42,7 +42,8 @@
>  
>  #if defined(CONFIG_ARCH_LUBBOCK) ||\
>      defined(CONFIG_MACH_MAINSTONE) ||\
> -    defined(CONFIG_MACH_ZYLONITE)
> +    defined(CONFIG_MACH_ZYLONITE) ||\
> +    defined(CONFIG_MACH_LITTLETON)
>  
>  #include <asm/mach-types.h>
>  
> -- 
> 1.5.4.3
> 


Nicolas
