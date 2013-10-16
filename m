From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] sh_eth: add/use RMCR.RNC bit
Date: Wed, 16 Oct 2013 09:34:59 +0900
Message-ID: <20131016003459.GN22321@verge.net.au>
References: <201310160229.58735.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org, davem@davemloft.net
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201310160229.58735.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 16, 2013 at 02:29:58AM +0400, Sergei Shtylyov wrote:
> Declare 'enum EMCR_BIT' containing the single member for the RMCR.RNC bit and
> replace bare numbers in the driver by  this mnemonic.
> 
> Suggested-by: David Miller <davem@davemloft.net>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Thanks Sergei,

this seems to move things in the right direction.

Reviewed-by: Simon Horman <horms+renesas@verge.net.au>

> ---
> This patch is against DaveM's 'net.git' repo but it intended for 'net-next.git'
> repo -- it's  because 'net-next.git' doesn't contain the required Simon Horman's
> patch yet.
> 
>  drivers/net/ethernet/renesas/sh_eth.c |    6 +++---
>  drivers/net/ethernet/renesas/sh_eth.h |    3 +++
>  2 files changed, 6 insertions(+), 3 deletions(-)
> 
> Index: net/drivers/net/ethernet/renesas/sh_eth.c
> ===================================================================
> --- net.orig/drivers/net/ethernet/renesas/sh_eth.c
> +++ net/drivers/net/ethernet/renesas/sh_eth.c
> @@ -483,7 +483,7 @@ static struct sh_eth_cpu_data sh7757_dat
>  	.register_type	= SH_ETH_REG_FAST_SH4,
>  
>  	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
> -	.rmcr_value	= 0x00000001,
> +	.rmcr_value	= RMCR_RNC,
>  
>  	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
>  	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
> @@ -561,7 +561,7 @@ static struct sh_eth_cpu_data sh7757_dat
>  			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
>  			  EESR_TDE | EESR_ECI,
>  	.fdr_value	= 0x0000072f,
> -	.rmcr_value	= 0x00000001,
> +	.rmcr_value	= RMCR_RNC,
>  
>  	.irq_flags	= IRQF_SHARED,
>  	.apr		= 1,
> @@ -689,7 +689,7 @@ static struct sh_eth_cpu_data r8a7740_da
>  			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
>  			  EESR_TDE | EESR_ECI,
>  	.fdr_value	= 0x0000070f,
> -	.rmcr_value	= 0x00000001,
> +	.rmcr_value	= RMCR_RNC,
>  
>  	.apr		= 1,
>  	.mpr		= 1,
> Index: net/drivers/net/ethernet/renesas/sh_eth.h
> ===================================================================
> --- net.orig/drivers/net/ethernet/renesas/sh_eth.h
> +++ net/drivers/net/ethernet/renesas/sh_eth.h
> @@ -321,6 +321,9 @@ enum TD_STS_BIT {
>  #define TD_TFP	(TD_TFP1|TD_TFP0)
>  
>  /* RMCR */
> +enum RMCR_BIT {
> +	RMCR_RNC = 0x00000001,
> +};
>  #define DEFAULT_RMCR_VALUE	0x00000000
>  
>  /* ECMR */
> 
