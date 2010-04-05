From: Sathya Perla <sathyap@serverengines.com>
Subject: Re: [PATCH 2/2] benet: fix the misusage of zero dma address
Date: Mon, 5 Apr 2010 13:52:02 +0530
Message-ID: <20100405082202.GB32671@serverengines.com>
References: <1270176803-8561-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1270176803-8561-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <20100405071059.GA32671@serverengines.com>
 <20100405163942P.fujita.tomonori@lab.ntt.co.jp>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sathyap@serverengines.com, subbus@serverengines.com,
	sarveshwarb@serverengines.com, ajitk@serverengines.com,
	netdev@vger.kernel.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:45796 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751223Ab0DEIWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 04:22:31 -0400
Content-Disposition: inline
In-Reply-To: <20100405163942P.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/10 16:40 +0900, FUJITA Tomonori wrote:
> > > +		wrb->frag_len = 0;
> > Why does wrb->frag_len need to be reset here?
> > In the TX path, it is set to the proper value for data wrbs and zero
> > for dummy and hdr wrbs.
> 
> I guess that I misunderstood why unmap_tx_frag() checks a dma address.
> The checking is necessary to avoid calling pci_unamp_* API for dummy
> hdr wrbs?
Yes.
> 
> Anyway, if wrb->frag_len doesn't need to be reset here, the following
> patch is ok?
Yes. Thanks.

Acked-by: Sathya Perla <sathyap@serverengines.com>
> 
> =
> From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> Subject: [PATCH v2 2/2] benet: fix the misusage of zero dma address
> 
> benet driver wrongly assumes that zero is an invalid dma address
> (calls dma_unmap_page for only non zero dma addresses). Zero is a
> valid dma address on some architectures. The dma length can be used
> here.
> 
> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> ---
>  drivers/net/benet/be_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
> index a27a0a1..c95e1a2 100644
> --- a/drivers/net/benet/be_main.c
> +++ b/drivers/net/benet/be_main.c
> @@ -404,7 +404,7 @@ static void unmap_tx_frag(struct pci_dev *pdev, struct be_eth_wrb *wrb,
>  	be_dws_le_to_cpu(wrb, sizeof(*wrb));
>  
>  	dma = (u64)wrb->frag_pa_hi << 32 | (u64)wrb->frag_pa_lo;
> -	if (dma != 0) {
> +	if (wrb->frag_len) {
>  		if (unmap_single)
>  			pci_unmap_single(pdev, dma, wrb->frag_len,
>  				PCI_DMA_TODEVICE);
> -- 
> 1.7.0
> 
> 
