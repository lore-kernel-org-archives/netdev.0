From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [PATCH] net: axienet: Remove unused parameter from
 __axienet_device_reset
Date: Thu, 13 Oct 2016 14:23:49 +0200
Message-ID: <9b966409-bdd5-08d1-564e-d7900b4707d1@xilinx.com>
References: <20161013112833.7581-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Michal Simek <michal.simek@xilinx.com>,
        =?UTF-8?Q?S=c3=b6ren_Brinkmann?= <soren.brinkmann@xilinx.com>,
        <netdev@vger.kernel.org>
To: Tobias Klauser <tklauser@distanz.ch>,
        Anirudha Sarangi <anirudh@xilinx.com>,
        John Linn <John.Linn@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0045.outbound.protection.outlook.com ([104.47.36.45]:51968
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1756556AbcJMQE5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Oct 2016 12:04:57 -0400
In-Reply-To: <20161013112833.7581-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13.10.2016 13:28, Tobias Klauser wrote:
> The dev parameter passed to __axienet_device_reset() is not used inside
> the function, so remove it.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
>  drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> index 35f9f9742a48..c688d68c39aa 100644
> --- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> +++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> @@ -431,8 +431,7 @@ static void axienet_setoptions(struct net_device *ndev, u32 options)
>  	lp->options |= options;
>  }
>  
> -static void __axienet_device_reset(struct axienet_local *lp,
> -				   struct device *dev, off_t offset)
> +static void __axienet_device_reset(struct axienet_local *lp, off_t offset)
>  {
>  	u32 timeout;
>  	/* Reset Axi DMA. This would reset Axi Ethernet core as well. The reset
> @@ -468,8 +467,8 @@ static void axienet_device_reset(struct net_device *ndev)
>  	u32 axienet_status;
>  	struct axienet_local *lp = netdev_priv(ndev);
>  
> -	__axienet_device_reset(lp, &ndev->dev, XAXIDMA_TX_CR_OFFSET);
> -	__axienet_device_reset(lp, &ndev->dev, XAXIDMA_RX_CR_OFFSET);
> +	__axienet_device_reset(lp, XAXIDMA_TX_CR_OFFSET);
> +	__axienet_device_reset(lp, XAXIDMA_RX_CR_OFFSET);
>  
>  	lp->max_frm_size = XAE_MAX_VLAN_FRAME_SIZE;
>  	lp->options |= XAE_OPTION_VLAN;
> @@ -1338,8 +1337,8 @@ static void axienet_dma_err_handler(unsigned long data)
>  	axienet_iow(lp, XAE_MDIO_MC_OFFSET, (mdio_mcreg &
>  		    ~XAE_MDIO_MC_MDIOEN_MASK));
>  
> -	__axienet_device_reset(lp, &ndev->dev, XAXIDMA_TX_CR_OFFSET);
> -	__axienet_device_reset(lp, &ndev->dev, XAXIDMA_RX_CR_OFFSET);
> +	__axienet_device_reset(lp, XAXIDMA_TX_CR_OFFSET);
> +	__axienet_device_reset(lp, XAXIDMA_RX_CR_OFFSET);
>  
>  	axienet_iow(lp, XAE_MDIO_MC_OFFSET, mdio_mcreg);
>  	axienet_mdio_wait_until_ready(lp);
> 

Can you please send this directly to mainline?
And put my:
Reviewed-by: Michal Simek <michal.simek@xilinx.com>

Thanks,
Michal
