From: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Subject: Re: [PATCH v3 07/20] wireless: ipw2200: Replace PCI pool old API
Date: Mon, 27 Feb 2017 12:09:21 +0100
Message-ID: <20170227110921.GB26544@collabora.com>
References: <20170226192425.13098-1-romain.perier@collabora.com>
 <20170226192425.13098-8-romain.perier@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        "James E.J. Bottomley" <jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        "Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Felipe Balbi <balbi-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Peter Senna Tschudin <peter.senna-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
To: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170226192425.13098-8-romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 26, 2017 at 08:24:12PM +0100, Romain Perier wrote:
> The PCI pool API is deprecated. This commits replaces the PCI pool old
> API by the appropriated function with the DMA pool API.
> 
Reviewed-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
> Signed-off-by: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
> ---
>  drivers/net/wireless/intel/ipw2x00/ipw2200.c | 13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/wireless/intel/ipw2x00/ipw2200.c b/drivers/net/wireless/intel/ipw2x00/ipw2200.c
> index 5ef3c5c..93dfe47 100644
> --- a/drivers/net/wireless/intel/ipw2x00/ipw2200.c
> +++ b/drivers/net/wireless/intel/ipw2x00/ipw2200.c
> @@ -3211,7 +3211,7 @@ static int ipw_load_firmware(struct ipw_priv *priv, u8 * data, size_t len)
>  	struct fw_chunk *chunk;
>  	int total_nr = 0;
>  	int i;
> -	struct pci_pool *pool;
> +	struct dma_pool *pool;
>  	void **virts;
>  	dma_addr_t *phys;
>  
> @@ -3228,9 +3228,10 @@ static int ipw_load_firmware(struct ipw_priv *priv, u8 * data, size_t len)
>  		kfree(virts);
>  		return -ENOMEM;
>  	}
> -	pool = pci_pool_create("ipw2200", priv->pci_dev, CB_MAX_LENGTH, 0, 0);
> +	pool = dma_pool_create("ipw2200", &priv->pci_dev->dev, CB_MAX_LENGTH, 0,
> +			       0);
>  	if (!pool) {
> -		IPW_ERROR("pci_pool_create failed\n");
> +		IPW_ERROR("dma_pool_create failed\n");
>  		kfree(phys);
>  		kfree(virts);
>  		return -ENOMEM;
> @@ -3255,7 +3256,7 @@ static int ipw_load_firmware(struct ipw_priv *priv, u8 * data, size_t len)
>  
>  		nr = (chunk_len + CB_MAX_LENGTH - 1) / CB_MAX_LENGTH;
>  		for (i = 0; i < nr; i++) {
> -			virts[total_nr] = pci_pool_alloc(pool, GFP_KERNEL,
> +			virts[total_nr] = dma_pool_alloc(pool, GFP_KERNEL,
>  							 &phys[total_nr]);
>  			if (!virts[total_nr]) {
>  				ret = -ENOMEM;
> @@ -3299,9 +3300,9 @@ static int ipw_load_firmware(struct ipw_priv *priv, u8 * data, size_t len)
>  	}
>   out:
>  	for (i = 0; i < total_nr; i++)
> -		pci_pool_free(pool, virts[i], phys[i]);
> +		dma_pool_free(pool, virts[i], phys[i]);
>  
> -	pci_pool_destroy(pool);
> +	dma_pool_destroy(pool);
>  	kfree(phys);
>  	kfree(virts);
>  
> -- 
> 2.9.3
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
