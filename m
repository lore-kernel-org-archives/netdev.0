From: Kyle McMartin <kyle@mcmartin.ca>
Subject: Re: Null dereference in uli526x_rx_packet()
Date: Fri, 27 Mar 2009 22:47:54 -0400
Message-ID: <20090328024754.GA16554@bombadil.infradead.org>
References: <Pine.LNX.4.64.0903270801020.5354@usbsys.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: grundler@parisc-linux.org, kyle@mcmartin.ca, netdev@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:55347 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755232AbZC1CsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 22:48:00 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0903270801020.5354@usbsys.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 27, 2009 at 01:31:36PM +0300, Dan Carpenter wrote:
> Smatch (http://repo.or.cz/w/smatch.git/) complains about the error 
> handling in uli526x_rx_packet().
> 
> I don't know if the right fix is to return like this patch does or to set 
> skb = rxptr->rx_skb_ptr again.
> 

Ick... that's a good catch. I'll have to think about this.

regards, Kyle

> --- orig/drivers/net/tulip/uli526x.c	2009-03-27 07:52:32.000000000 +0300
> +++ devel/drivers/net/tulip/uli526x.c	2009-03-27 07:57:05.000000000 +0300
> @@ -844,10 +844,13 @@
>  
>  				/* Good packet, send to upper layer */
>  				/* Shorst packet used new SKB */
> -				if ( (rxlen < RX_COPY_SIZE) &&
> -					( (skb = dev_alloc_skb(rxlen + 2) )
> -					!= NULL) ) {
> -					/* size less than COPY_SIZE, allocate a rxlen SKB */
> +				/* size less than COPY_SIZE, allocate a rxlen SKB */
> +				if (rxlen < RX_COPY_SIZE) {
> +					skb = dev_alloc_skb(rxlen + 2);
> +					if (!skb)
> +						return;
> +				}
> +				if (rxlen < RX_COPY_SIZE) {
>  					skb_reserve(skb, 2); /* 16byte align */
>  					memcpy(skb_put(skb, rxlen),
>  					       skb_tail_pointer(rxptr->rx_skb_ptr),
> 
