From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] sh_eth: r8a7790: Handle the RFE (Receive FIFO overflow
 Error) interrupt
Date: Tue, 30 Jul 2013 11:10:25 +0900
Message-ID: <20130730021025.GC27724@verge.net.au>
References: <1375142928-17769-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1375142928-17769-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 30, 2013 at 02:08:48AM +0200, Laurent Pinchart wrote:
> The RFE interrupt is enabled for the r8a7790 but isn't handled,
> resulting in the interrupts core noticing unhandled interrupts, and
> eventually disabling the ethernet IRQ.
> 
> Fix it by adding RFE to the bitmask of error interrupts to be handled
> for r8a7790.
> 
> Signed-off-by: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>

This looks good to me:

Reviewed-by: Simon Horman <horms+renesas@verge.net.au>

> ---
>  drivers/net/ethernet/renesas/sh_eth.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index fedc0a0..9e2afe8 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -403,8 +403,9 @@ static struct sh_eth_cpu_data r8a7790_data = {
>  	.eesipr_value	= 0x01ff009f,
>  
>  	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
> -	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RDE |
> -			  EESR_RFRMER | EESR_TFE | EESR_TDE | EESR_ECI,
> +	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
> +			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE |
> +			  EESR_ECI,
>  
>  	.apr		= 1,
>  	.mpr		= 1,
> -- 
> Regards,
> 
> Laurent Pinchart
> 
