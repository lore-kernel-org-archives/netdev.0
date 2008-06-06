From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 29/39] mv643xx_eth: general cleanup
Date: Fri, 6 Jun 2008 03:59:19 -0700
Message-ID: <20080606105919.GD5499@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-30-git-send-email-buytenh@wantstofly.org> <20080605123306.GN3807@farnsworth.org> <20080606082434.GD5420@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:46565 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751488AbYFFK72 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 06:59:28 -0400
Content-Disposition: inline
In-Reply-To: <20080606082434.GD5420@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 06, 2008 at 10:24:35AM +0200, Lennert Buytenhek wrote:
> On Thu, Jun 05, 2008 at 05:33:06AM -0700, Dale Farnsworth wrote:
> 
> > > @@ -441,7 +445,7 @@ static void rxq_refill(struct rx_queue *rxq)
> > >  						RX_ENABLE_INTERRUPT;
> > >  		wmb();
> > >  
> > > -		skb_reserve(skb, ETH_HW_IP_ALIGN);
> > > +		skb_reserve(skb, 2);
> > 
> > I think you've removed some useful documentation here.  Either keep the
> > define or add a comment explaining what the 2 is for.

[snip]

> I've folded the following patch into the patch.  OK?
> Index: linux-2.6.26-rc5/drivers/net/mv643xx_eth.c
> ===================================================================
> --- linux-2.6.26-rc5.orig/drivers/net/mv643xx_eth.c
> +++ linux-2.6.26-rc5/drivers/net/mv643xx_eth.c
> @@ -454,6 +454,11 @@ static void rxq_refill(struct rx_queue *
>  						RX_ENABLE_INTERRUPT;
>  		wmb();
>  
> +		/*
> +		 * The hardware automatically prepends 2 bytes of
> +		 * dummy data to each received packet, so that the
> +		 * IP header ends up 16-byte aligned.
> +		 */
>  		skb_reserve(skb, 2);
>  	}
>  
> @@ -508,7 +513,11 @@ static int rxq_process(struct rx_queue *
>  
>  		/*
>  		 * Update statistics.
> -		 * Note byte count includes 4 byte CRC count
> +		 *
> +		 * Note that the descriptor byte count includes 2 dummy
> +		 * bytes automatically inserted by the hardware at the
> +		 * start of the packet (which we don't count), and a 4
> +		 * byte CRC at the end of the packet (which we do count).
>  		 */
>  		stats->rx_packets++;
>  		stats->rx_bytes += rx_desc->byte_cnt - 2;
> @@ -999,6 +1008,7 @@ static int mv643xx_eth_nway_reset(struct
>  static u32 mv643xx_eth_get_link(struct net_device *dev)
>  {
>  	struct mv643xx_eth_private *mp = netdev_priv(dev);
> +
>  	return mii_link_ok(&mp->mii);
>  }

Looks good.

-Dale
