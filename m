From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] tehuti: possible leak in bdx_probe
Date: Mon, 15 Oct 2007 09:33:09 -0400
Message-ID: <20071015133309.GI9140@gospo.rdu.redhat.com>
References: <4710FA6A.2070902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: baum@tehutinetworks.net, andy@greyhouse.net,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Florin Malita <fmalita@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47818 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762330AbXJONhy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 09:37:54 -0400
Content-Disposition: inline
In-Reply-To: <4710FA6A.2070902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 13, 2007 at 01:03:38PM -0400, Florin Malita wrote:
> If pci_enable_device fails, bdx_probe returns without freeing the 
> allocated pci_nic structure.
> 
> Coverity CID 1908.
> 
> Signed-off-by: Florin Malita <fmalita@gmail.com>
> ---
> 
> drivers/net/tehuti.c |    3 ++-
> 1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
> index 8d04654..4e1b84e 100644
> --- a/drivers/net/tehuti.c
> +++ b/drivers/net/tehuti.c
> @@ -1906,7 +1906,7 @@ bdx_probe(struct pci_dev *pdev, const struct 
> pci_device_id *ent)
> 
>     /************** pci *****************/
> 	if ((err = pci_enable_device(pdev)))	/* it trigers interrupt, 
> 	dunno why. */
> -		RET(err);			/* it's not a problem though 
> */
> +		goto err_pci;			/* it's not a problem though 
> */
> 
> 	if (!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK)) &&
> 	    !(err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK))) {
> @@ -2076,6 +2076,7 @@ err_out_res:
> 	pci_release_regions(pdev);
> err_dma:
> 	pci_disable_device(pdev);
> +err_pci:
> 	vfree(nic);
> 
> 	RET(err);
> 

Good catch.  Thanks!

Acked-by: Andy Gospodarek <andy@greyhouse.net>

