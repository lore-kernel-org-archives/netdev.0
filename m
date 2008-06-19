From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH 4/8] smc91x: add SMC91X_NOWAIT flag to platform data
Date: Thu, 19 Jun 2008 12:06:11 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0806191205500.2982@xanadu.home>
References: <485A3DCB.90903@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-netdev <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	Magnus Damm <magnus.damm@gmail.com>
To: Eric Miao <eric.y.miao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:52913 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751351AbYFSQGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 12:06:11 -0400
Received: from xanadu.home ([66.131.194.97]) by VL-MH-MR001.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0K2P002TUWQB8U20@VL-MH-MR001.ip.videotron.ca> for
 netdev@vger.kernel.org; Thu, 19 Jun 2008 12:06:11 -0400 (EDT)
In-reply-to: <485A3DCB.90903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Jun 2008, Eric Miao wrote:

> 
> And also favors the usage of SMC91X_NOWAIT over the hardcoded SMC_NOWAIT
> by converting "nowait" (module parameter overridable) to platform flag.
> 
> There are several possibilities:
> 
>   1. platform data present - preferred and use as is
>   2. platform data absent  - use "nowait", it can be:
>        a. SMC_NOWAIT if defined
>        b. default to 0 if SMC_NOWAIT isn't defined
>        c. overriden by module parameter
> 
> Signed-off-by: Eric Miao <eric.miao@marvell.com>

Acked-by: Nicolas Pitre <nico@cam.org>

> ---
>  drivers/net/smc91x.c   |    3 ++-
>  include/linux/smc91x.h |    2 ++
>  2 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
> index b57ee44..caa0308 100644
> --- a/drivers/net/smc91x.c
> +++ b/drivers/net/smc91x.c
> @@ -279,7 +279,7 @@ static void smc_reset(struct net_device *dev)
>  	 * can't handle it then there will be no recovery except for
>  	 * a hard reset or power cycle
>  	 */
> -	if (nowait)
> +	if (lp->cfg.flags & SMC91X_NOWAIT)
>  		cfg |= CONFIG_NO_WAIT;
>  
>  	/*
> @@ -2142,6 +2142,7 @@ static int smc_drv_probe(struct platform_device *pdev)
>  		lp->cfg.flags |= (SMC_CAN_USE_8BIT)  ? SMC91X_USE_8BIT  : 0;
>  		lp->cfg.flags |= (SMC_CAN_USE_16BIT) ? SMC91X_USE_16BIT : 0;
>  		lp->cfg.flags |= (SMC_CAN_USE_32BIT) ? SMC91X_USE_32BIT : 0;
> +		lp->cfg.flags |= (nowait) ? SMC91X_NOWAIT : 0;
>  	}
>  
>  	ndev->dma = (unsigned char)-1;
> diff --git a/include/linux/smc91x.h b/include/linux/smc91x.h
> index fc7682f..90434db 100644
> --- a/include/linux/smc91x.h
> +++ b/include/linux/smc91x.h
> @@ -5,6 +5,8 @@
>  #define SMC91X_USE_16BIT (1 << 1)
>  #define SMC91X_USE_32BIT (1 << 2)
>  
> +#define SMC91X_NOWAIT		(1 << 3)
> +
>  struct smc91x_platdata {
>  	unsigned long flags;
>  };
> -- 
> 1.5.4.3
> 


Nicolas
