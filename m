From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH 3/8] smc91x: favor the use of SMC91X_USE_* instead of
 SMC_CAN_USE_*
Date: Thu, 19 Jun 2008 12:04:07 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0806191203450.2982@xanadu.home>
References: <485A3D86.60905@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-netdev <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	Magnus Damm <magnus.damm@gmail.com>
To: Eric Miao <eric.y.miao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:38620 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751477AbYFSQEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 12:04:32 -0400
Received: from xanadu.home ([66.131.194.97]) by VL-MH-MR001.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0K2P002V2WMV8R20@VL-MH-MR001.ip.videotron.ca> for
 netdev@vger.kernel.org; Thu, 19 Jun 2008 12:04:07 -0400 (EDT)
In-reply-to: <485A3D86.60905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Jun 2008, Eric Miao wrote:

> 
> Let's simplify the logic and avoid confusion, the use of SMC91X_USE_*
> is favored than SMC_CAN_USE_*, if platform data isn't given, convert
> the hardcoded SMC_CAN_USE_* to SMC91X_USE_*.
> 
> Signed-off-by: Eric Miao <eric.miao@marvell.com>

Acked-by: Nicolas Pitre <nico@cam.org>

> ---
>  drivers/net/smc91x.c |   12 +++---------
>  drivers/net/smc91x.h |   13 +++----------
>  2 files changed, 6 insertions(+), 19 deletions(-)
> 
> diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
> index 70a19ad..b57ee44 100644
> --- a/drivers/net/smc91x.c
> +++ b/drivers/net/smc91x.c
> @@ -2136,20 +2136,14 @@ static int smc_drv_probe(struct platform_device *pdev)
>  
>  	lp = netdev_priv(ndev);
>  
> -#ifdef SMC_DYNAMIC_BUS_CONFIG
>  	if (pd)
>  		memcpy(&lp->cfg, pd, sizeof(lp->cfg));
>  	else {
> -		lp->cfg.flags = SMC91X_USE_8BIT;
> -		lp->cfg.flags |= SMC91X_USE_16BIT;
> -		lp->cfg.flags |= SMC91X_USE_32BIT;
> +		lp->cfg.flags |= (SMC_CAN_USE_8BIT)  ? SMC91X_USE_8BIT  : 0;
> +		lp->cfg.flags |= (SMC_CAN_USE_16BIT) ? SMC91X_USE_16BIT : 0;
> +		lp->cfg.flags |= (SMC_CAN_USE_32BIT) ? SMC91X_USE_32BIT : 0;
>  	}
>  
> -	lp->cfg.flags &= ~(SMC_CAN_USE_8BIT ? 0 : SMC91X_USE_8BIT);
> -	lp->cfg.flags &= ~(SMC_CAN_USE_16BIT ? 0 : SMC91X_USE_16BIT);
> -	lp->cfg.flags &= ~(SMC_CAN_USE_32BIT ? 0 : SMC91X_USE_32BIT);
> -#endif
> -
>  	ndev->dma = (unsigned char)-1;
>  
>  	ires = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
> diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
> index 97a3c52..6a90400 100644
> --- a/drivers/net/smc91x.h
> +++ b/drivers/net/smc91x.h
> @@ -441,7 +441,6 @@ static inline void LPD7_SMC_outsw (unsigned char* a, int r,
>  #define RPC_LSA_DEFAULT		RPC_LED_100_10
>  #define RPC_LSB_DEFAULT		RPC_LED_TX_RX
>  
> -#define SMC_DYNAMIC_BUS_CONFIG
>  #endif
>  
>  
> @@ -491,15 +490,9 @@ struct smc_local {
>  	struct smc91x_platdata cfg;
>  };
>  
> -#ifdef SMC_DYNAMIC_BUS_CONFIG
> -#define SMC_8BIT(p) (((p)->cfg.flags & SMC91X_USE_8BIT) && SMC_CAN_USE_8BIT)
> -#define SMC_16BIT(p) (((p)->cfg.flags & SMC91X_USE_16BIT) && SMC_CAN_USE_16BIT)
> -#define SMC_32BIT(p) (((p)->cfg.flags & SMC91X_USE_32BIT) && SMC_CAN_USE_32BIT)
> -#else
> -#define SMC_8BIT(p) SMC_CAN_USE_8BIT
> -#define SMC_16BIT(p) SMC_CAN_USE_16BIT
> -#define SMC_32BIT(p) SMC_CAN_USE_32BIT
> -#endif
> +#define SMC_8BIT(p)	((p)->cfg.flags & SMC91X_USE_8BIT)
> +#define SMC_16BIT(p)	((p)->cfg.flags & SMC91X_USE_16BIT)
> +#define SMC_32BIT(p)	((p)->cfg.flags & SMC91X_USE_32BIT)
>  
>  #ifdef SMC_USE_PXA_DMA
>  /*
> -- 
> 1.5.4.3
> 


Nicolas
