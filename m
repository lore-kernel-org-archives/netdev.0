From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 1/2] bnx2x: dont handle storage drv_info req if
 no cnic
Date: Wed, 07 Dec 2011 09:04:00 -0800
Message-ID: <1323277440.1762.46.camel@joe2Laptop>
References: <Barak Witkowski <barak@broadcom.com>
	 <1323265536-9760-1-git-send-email-barak@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>
To: Barak Witkowski <barak@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:46172 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757453Ab1LGREC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Dec 2011 12:04:02 -0500
In-Reply-To: <1323265536-9760-1-git-send-email-barak@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-12-07 at 15:45 +0200, Barak Witkowski wrote:
> This patch returns ACK with zeroed buffer to FW upon fcoe/iscsi drv_info
> request if cnic is not defined. This is better handling in comparison to
> send NACK to FW upon such request, as it's a valid request.

Hi Barak.

Other than the good comment,
I think this patch isn't useful.
It adds maintenance overhead.

It just adds more #ifdefs.

gcc should remove the call to the
empty static void funcs.

> Reported-by: Joe Perches <joe@perches.com>
> Signed-off-by: Barak Witkowski <barak@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   12 ++++++++----
>  1 files changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> index 418e7d3..d104695 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -2941,9 +2941,9 @@ static void bnx2x_drv_info_ether_stat(struct bnx2x *bp)
>  	ether_stat->rxq_size = bp->rx_ring_size;
>  }
>  
> +#ifdef BCM_CNIC
>  static void bnx2x_drv_info_fcoe_stat(struct bnx2x *bp)
>  {
> -#ifdef BCM_CNIC
>  	struct bnx2x_dcbx_app_params *app = &bp->dcbx_port_params.app;
>  	struct fcoe_stats_info *fcoe_stat =
>  		&bp->slowpath->drv_info_to_mcp.fcoe_stat;
> @@ -3029,12 +3029,12 @@ static void bnx2x_drv_info_fcoe_stat(struct bnx2x *bp)
>  
>  	/* ask L5 driver to add data to the struct */
>  	bnx2x_cnic_notify(bp, CNIC_CTL_FCOE_STATS_GET_CMD);
> -#endif
>  }
> +#endif
>  
> +#ifdef BCM_CNIC
>  static void bnx2x_drv_info_iscsi_stat(struct bnx2x *bp)
>  {
> -#ifdef BCM_CNIC
>  	struct bnx2x_dcbx_app_params *app = &bp->dcbx_port_params.app;
>  	struct iscsi_stats_info *iscsi_stat =
>  		&bp->slowpath->drv_info_to_mcp.iscsi_stat;
> @@ -3046,8 +3046,8 @@ static void bnx2x_drv_info_iscsi_stat(struct bnx2x *bp)
>  
>  	/* ask L5 driver to add data to the struct */
>  	bnx2x_cnic_notify(bp, CNIC_CTL_ISCSI_STATS_GET_CMD);
> -#endif
>  }
> +#endif
>  
>  /* called due to MCP event (on pmf):
>   *	reread new bandwidth configuration
> @@ -3091,10 +3091,14 @@ static void bnx2x_handle_drv_info_req(struct bnx2x *bp)
>  		bnx2x_drv_info_ether_stat(bp);
>  		break;
>  	case FCOE_STATS_OPCODE:
> +#ifdef BCM_CNIC
>  		bnx2x_drv_info_fcoe_stat(bp);
> +#endif
>  		break;
>  	case ISCSI_STATS_OPCODE:
> +#ifdef BCM_CNIC
>  		bnx2x_drv_info_iscsi_stat(bp);
> +#endif
>  		break;
>  	default:
>  		/* if op code isn't supported - send NACK */
