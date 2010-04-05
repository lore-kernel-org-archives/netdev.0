From: Sathya Perla <sathyap@serverengines.com>
Subject: Re: [PATCH 1/2] benet: use the dma state API instead of the pci
 equivalents
Date: Mon, 5 Apr 2010 14:34:57 +0530
Message-ID: <20100405090457.GA2541@serverengines.com>
References: <1270176803-8561-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sathyap@serverengines.com, subbus@serverengines.com,
	sarveshwarb@serverengines.com, ajitk@serverengines.com,
	netdev@vger.kernel.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:58559 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751025Ab0DEJF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 05:05:27 -0400
Content-Disposition: inline
In-Reply-To: <1270176803-8561-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks.

Acked-by: Sathya Perla <sathyap@serverengines.com>

On 02/04/10 11:53 +0900, FUJITA Tomonori wrote:
> The DMA API is preferred.
> 
> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> ---
>  drivers/net/benet/be.h      |    2 +-
>  drivers/net/benet/be_main.c |    4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
> index 8f07525..bddae08 100644
> --- a/drivers/net/benet/be.h
> +++ b/drivers/net/benet/be.h
> @@ -206,7 +206,7 @@ struct be_tx_obj {
>  /* Struct to remember the pages posted for rx frags */
>  struct be_rx_page_info {
>  	struct page *page;
> -	dma_addr_t bus;
> +	DEFINE_DMA_UNMAP_ADDR(bus);
>  	u16 page_offset;
>  	bool last_page_user;
>  };
> diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
> index 17282df..8d5e27b 100644
> --- a/drivers/net/benet/be_main.c
> +++ b/drivers/net/benet/be_main.c
> @@ -682,7 +682,7 @@ get_rx_page_info(struct be_adapter *adapter, u16 frag_idx)
>  	BUG_ON(!rx_page_info->page);
>  
>  	if (rx_page_info->last_page_user) {
> -		pci_unmap_page(adapter->pdev, pci_unmap_addr(rx_page_info, bus),
> +		pci_unmap_page(adapter->pdev, dma_unmap_addr(rx_page_info, bus),
>  			adapter->big_page_size, PCI_DMA_FROMDEVICE);
>  		rx_page_info->last_page_user = false;
>  	}
> @@ -993,7 +993,7 @@ static void be_post_rx_frags(struct be_adapter *adapter)
>  		}
>  		page_offset = page_info->page_offset;
>  		page_info->page = pagep;
> -		pci_unmap_addr_set(page_info, bus, page_dmaaddr);
> +		dma_unmap_addr_set(page_info, bus, page_dmaaddr);
>  		frag_dmaaddr = page_dmaaddr + page_info->page_offset;
>  
>  		rxd = queue_head_node(rxq);
> -- 
> 1.7.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
