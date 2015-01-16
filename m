From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: Re: [PATCH] ethernet: atheros: Add nss-gmac driver
Date: Thu, 15 Jan 2015 18:00:40 -0800
Message-ID: <20150115180040.180fdbb9@urahara>
References: <y>
	<1420754626-30121-1-git-send-email-wstephen@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jcliburn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stephen Wang <wstephen-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420754626-30121-1-git-send-email-wstephen-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu,  8 Jan 2015 14:03:46 -0800
Stephen Wang <wstephen-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> wrote:

> +static int32_t nss_gmac_setup_tx_desc_queue(struct nss_gmac_dev *gmacdev,
> +						struct device *dev,
> +						uint32_t no_of_desc,
> +						uint32_t desc_mode)
> +{
> +	int32_t i;
> +	struct dma_desc *first_desc = NULL;
> +	dma_addr_t dma_addr;
> +
> +	gmacdev->tx_desc_count = 0;
> +
> +	BUG_ON(desc_mode != RINGMODE);
> +	BUG_ON((no_of_desc & (no_of_desc - 1)) != 0);
> +
> +	netdev_dbg(gmacdev->netdev, "Total size of memory required for Tx Descriptors in Ring Mode = 0x%08x"
> +			, (uint32_t) ((sizeof(struct dma_desc) * no_of_desc)));
> +
> +	first_desc = dma_alloc_coherent(dev, sizeof(struct dma_desc) * no_of_desc
> +					, &dma_addr, GFP_KERNEL);
> +	if (first_desc == NULL) {

In a lot of places you first initialize a variable then assign it 5 lines
later to it's initial value.  Get rid of the first initialization.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
