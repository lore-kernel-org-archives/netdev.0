From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 03/32] sfc: Remove parentheses around return
 expressions, reported by checkpatch
Date: Mon, 30 Jan 2012 16:45:49 +0000
Message-ID: <1327941949.2595.0.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
	 <1327696976.2503.10.camel@bwh-desktop>
	 <1327698066.18858.3.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:60328 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753861Ab2A3QqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 11:46:09 -0500
In-Reply-To: <1327698066.18858.3.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-01-27 at 13:01 -0800, Joe Perches wrote:
> On Fri, 2012-01-27 at 20:42 +0000, Ben Hutchings wrote:
> > Fix the following error:
> > ERROR: return is not a function, parentheses are not required
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> trivia:
> 
> > diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
> []
> > @@ -98,8 +98,8 @@ static inline unsigned int efx_rx_buf_offset(struct efx_nic *efx,
> >  	/* Offset is always within one page, so we don't need to consider
> >  	 * the page order.
> >  	 */
> > -	return (((__force unsigned long) buf->dma_addr & (PAGE_SIZE - 1)) +
> > -		efx->type->rx_buffer_hash_size);
> > +	return ((__force unsigned long) buf->dma_addr & (PAGE_SIZE - 1)) +
> > +		efx->type->rx_buffer_hash_size;
> >  }
> 
> The function returns unsigned int, perhaps the
> cast should be (__force unsigned int) or the
> function should return unsigned long or maybe
> size_t?

It's a page offset, so I believe unsigned int is correct.  This function
used to use the virtual address, and the compiler will warn about
casting a pointer to an integer of smaller size.  Now that it's using
the DMA address, this no longer applies (and __force is not necessary
either).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
