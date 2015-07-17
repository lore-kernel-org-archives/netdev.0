From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] bcmsysport:Fix error handling in the function bcm_sysport_init_rx_ring
Date: Fri, 17 Jul 2015 10:08:13 -0700
Message-ID: <55A9367D.6040001@gmail.com>
References: <1437135231-27511-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437135231-27511-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17/07/15 05:13, Nicholas Krause wrote:
> This fixes the error handling in the function bcm_sysport_init_rx_ringi
> after calling the function rdma_enable_set to make sure the return value 
> is equal to zero and if not print on the console failed to enable RDMA
> for the device and return the failed error code returned by
> rdma_enable_set.

Subject should be starting with "net: systemport: ", otherwise, this
looks good to me:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Tested-by: Florian Fainelli <f.fainelli@gmail.com>

> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/bcmsysport.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
> index 4566cdf..27a7b36 100644
> --- a/drivers/net/ethernet/broadcom/bcmsysport.c
> +++ b/drivers/net/ethernet/broadcom/bcmsysport.c
> @@ -1365,7 +1365,12 @@ static int bcm_sysport_init_rx_ring(struct bcm_sysport_priv *priv)
>  	/* Initialize HW, ensure RDMA is disabled */
>  	reg = rdma_readl(priv, RDMA_STATUS);
>  	if (!(reg & RDMA_DISABLED))
> -		rdma_enable_set(priv, 0);
> +		ret = rdma_enable_set(priv, 0);
> +
> +	if (ret) {
> +		netif_err(priv, hw, priv->netdev, "failed to enable RDMA\n");
> +		return ret;
> +	}
>  
>  	rdma_writel(priv, 0, RDMA_WRITE_PTR_LO);
>  	rdma_writel(priv, 0, RDMA_WRITE_PTR_HI);
> 


-- 
Florian
