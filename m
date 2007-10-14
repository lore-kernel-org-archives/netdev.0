From: "Alexander Indenbaum" <baum@tehutinetworks.net>
Subject: RE: [PATCH] tehuti: possible leak in bdx_probe
Date: Sun, 14 Oct 2007 10:30:08 +0200
Message-ID: <20071014083007.A804575CAA@mail.tehutinetworks.net>
References: <4710FA6A.2070902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Andrew Morton'" <akpm@linux-foundation.org>,
	<netdev@vger.kernel.org>
To: "'Florin Malita'" <fmalita@gmail.com>, <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sharon-b-actcom.actcom.co.il ([192.114.83.18]:43972 "EHLO
	mail.tehutinetworks.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754143AbXJNI7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 04:59:45 -0400
In-Reply-To: <4710FA6A.2070902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Florin Malita [mailto:fmalita@gmail.com]
> 
> If pci_enable_device fails, bdx_probe returns without freeing the
> allocated pci_nic structure.
> 
> Coverity CID 1908.
> 
> Signed-off-by: Florin Malita <fmalita@gmail.com>

Looks fine to me.

Acked-by: Alexander Indenbaum <baum@tehutinetworks.net>

Thanks!

> ---
> 
>  drivers/net/tehuti.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
> index 8d04654..4e1b84e 100644
> --- a/drivers/net/tehuti.c
> +++ b/drivers/net/tehuti.c
> @@ -1906,7 +1906,7 @@ bdx_probe(struct pci_dev *pdev, const struct
> pci_device_id *ent)
> 
>      /************** pci *****************/
>  	if ((err = pci_enable_device(pdev)))	/* it trigers interrupt,
> dunno why. */
> -		RET(err);			/* it's not a problem though
*/
> +		goto err_pci;			/* it's not a problem though
*/
> 
>  	if (!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK)) &&
>  	    !(err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK))) {
> @@ -2076,6 +2076,7 @@ err_out_res:
>  	pci_release_regions(pdev);
>  err_dma:
>  	pci_disable_device(pdev);
> +err_pci:
>  	vfree(nic);
> 
>  	RET(err);



