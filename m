From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 29/39] mv643xx_eth: general cleanup
Date: Thu, 5 Jun 2008 05:33:06 -0700
Message-ID: <20080605123306.GN3807@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-30-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:60405 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755613AbYFEMdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 08:33:17 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-30-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:44PM +0200, Lennert Buytenhek wrote:
> General cleanup of the mv643xx_eth driver.  Mainly fixes coding
> style / indentation issues, get rid of some useless 'volatile's,
> kill some more superfluous comments, and such.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c   |  939 ++++++++++++++++++++-----------------------
>  include/linux/mv643xx_eth.h |   59 ++-
>  2 files changed, 469 insertions(+), 529 deletions(-)

[snip]

> @@ -441,7 +445,7 @@ static void rxq_refill(struct rx_queue *rxq)
>  						RX_ENABLE_INTERRUPT;
>  		wmb();
>  
> -		skb_reserve(skb, ETH_HW_IP_ALIGN);
> +		skb_reserve(skb, 2);

I think you've removed some useful documentation here.  Either keep the
define or add a comment explaining what the 2 is for.

>  	}
>  
>  	if (rxq->rx_desc_count == 0) {

[snip]

> @@ -498,24 +502,26 @@ static int rxq_process(struct rx_queue *rxq, int budget)
>  		 * Note byte count includes 4 byte CRC count
>  		 */
>  		stats->rx_packets++;
> -		stats->rx_bytes += rx_desc->byte_cnt - ETH_HW_IP_ALIGN;
> +		stats->rx_bytes += rx_desc->byte_cnt - 2;

Same comment here.

>  		/*
> -		 * In case received a packet without first / last bits on OR
> -		 * the error summary bit is on, the packets needs to be dropeed.
> +		 * In case we received a packet without first / last bits
> +		 * on, or the error summary bit is set, the packet needs
> +		 * to be dropped.
>  		 */
>  		if (((cmd_sts & (RX_FIRST_DESC | RX_LAST_DESC)) !=
>  					(RX_FIRST_DESC | RX_LAST_DESC))
>  				|| (cmd_sts & ERROR_SUMMARY)) {
>  			stats->rx_dropped++;
> +
>  			if ((cmd_sts & (RX_FIRST_DESC | RX_LAST_DESC)) !=
>  				(RX_FIRST_DESC | RX_LAST_DESC)) {
>  				if (net_ratelimit())
> -					printk(KERN_ERR
> -						"%s: Received packet spread "
> -						"on multiple descriptors\n",
> -						mep->dev->name);
> +					dev_printk(KERN_ERR, &mep->dev->dev,
> +						   "received packet spanning "
> +						   "multiple descriptors\n");
>  			}
> +
>  			if (cmd_sts & ERROR_SUMMARY)
>  				stats->rx_errors++;
>  

[snip]

> @@ -974,33 +990,31 @@ static int mv643xx_eth_nway_restart(struct net_device *dev)
>  static u32 mv643xx_eth_get_link(struct net_device *dev)
>  {
>  	struct mv643xx_eth_private *mep = netdev_priv(dev);
> -
>  	return mii_link_ok(&mep->mii);
>  }

Keep the blank line, IMHO.

[snip]

-Dale
