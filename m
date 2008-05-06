From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: fix simple define thinko
Date: Tue, 6 May 2008 16:18:43 -0700
Message-ID: <20080506161843.46a8eb83@extreme>
References: <20080506213435.25259.83781.stgit@jbrandeb-ich9b.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:53425 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753399AbYEFXS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 19:18:57 -0400
In-Reply-To: <20080506213435.25259.83781.stgit@jbrandeb-ich9b.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 06 May 2008 14:34:35 -0700
Jesse Brandeburg <jesse.brandeburg@intel.com> wrote:

> noticed while browsing code, apparent thinko.  compile tested only.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: Stephen Hemminger <shemminger@linux-foundation.org>
> ---
> 
>  drivers/net/sky2.h |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> 
> diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
> index 7bb3ba9..c0a5eea 100644
> --- a/drivers/net/sky2.h
> +++ b/drivers/net/sky2.h
> @@ -1966,13 +1966,13 @@ struct sky2_status_le {
>  struct tx_ring_info {
>  	struct sk_buff	*skb;
>  	DECLARE_PCI_UNMAP_ADDR(mapaddr);
> -	DECLARE_PCI_UNMAP_ADDR(maplen);
> +	DECLARE_PCI_UNMAP_LEN(maplen);
>  };
>  
>  struct rx_ring_info {
>  	struct sk_buff	*skb;
>  	dma_addr_t	data_addr;
> -	DECLARE_PCI_UNMAP_ADDR(data_size);
> +	DECLARE_PCI_UNMAP_LEN(data_size);
>  	dma_addr_t	frag_addr[ETH_JUMBO_MTU >> PAGE_SHIFT];
>  };
>  
> 

Yes, this looks okay. We were safe up till now because ADDR > LEN
