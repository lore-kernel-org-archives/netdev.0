From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/5] skge: use dev_alloc_skb
Date: Tue, 29 Aug 2006 12:23:36 +0100
Message-ID: <20060829112336.GA23975@infradead.org>
References: <20060828231934.477469235@localhost.localdomain> <20060828232038.303254635@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:7381 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S964928AbWH2LYG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 07:24:06 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060828232038.303254635@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 28, 2006 at 04:19:37PM -0700, Stephen Hemminger wrote:
> To avoid problems with buggy protocols that assume extra header space,
> use dev_alloc_skb() when allocating receive buffers.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> --- skge-2.6.orig/drivers/net/skge.c
> +++ skge-2.6/drivers/net/skge.c
> @@ -827,7 +827,8 @@ static int skge_rx_fill(struct skge_port
>  	do {
>  		struct sk_buff *skb;
>  
> -		skb = alloc_skb(skge->rx_buf_size + NET_IP_ALIGN, GFP_KERNEL);
> +		skb = __dev_alloc_skb(skge->rx_buf_size + NET_IP_ALIGN,
> +				      GFP_KERNEL);

While you're at it please use netdev_alloc_skb.

