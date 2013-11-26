From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 15/17] net: sfc calls skb_get_rxhash
Date: Tue, 26 Nov 2013 19:59:17 +0000
Message-ID: <1385495957.1586.54.camel@bwh-desktop.uk.level5networks.com>
References: <alpine.DEB.2.02.1311252156170.23058@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:25572 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754362Ab3KZT7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 14:59:22 -0500
In-Reply-To: <alpine.DEB.2.02.1311252156170.23058@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-25 at 21:57 -0800, Tom Herbert wrote:
> Drivers should call skb_get_rxhash to set the rxhash and its type
> in an skbuff.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  drivers/net/ethernet/sfc/rx.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
> index 8f09e68..b51466e 100644
> --- a/drivers/net/ethernet/sfc/rx.c
> +++ b/drivers/net/ethernet/sfc/rx.c
> @@ -439,7 +439,8 @@ efx_rx_packet_gro(struct efx_channel *channel, struct efx_rx_buffer *rx_buf,
>  	}
>  
>  	if (efx->net_dev->features & NETIF_F_RXHASH)
> -		skb->rxhash = efx_rx_buf_hash(efx, eh);
> +		skb_set_rxhash(skb, efx_rx_buf_hash(efx, eh),
> +			       RXHASH_TYPE_L3);

This is equivalent to what we do now.  But efx_rx_packet_gro() is only
ever called for TCP packets (checked in __efx_rx_packet()) and their
hashes include port numbers, so the hash type could be RXHASH_TYPE_L4.

Ben.

>  	skb->ip_summed = ((rx_buf->flags & EFX_RX_PKT_CSUMMED) ?
>  			  CHECKSUM_UNNECESSARY : CHECKSUM_NONE);
>  

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
