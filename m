From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 8/8] ewrk3: convert to set_phys_id
Date: Tue, 05 Apr 2011 00:21:19 +0100
Message-ID: <1301959279.2935.60.camel@localhost>
References: <20110404210634.840793593@linuxplumber.net>
	 <20110404210805.998401718@linuxplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:39808 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755591Ab1DDXVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 19:21:22 -0400
In-Reply-To: <20110404210805.998401718@linuxplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-04-04 at 14:06 -0700, Stephen Hemminger wrote:
> Keep orginal locking and error handling.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> 
> --- a/drivers/net/ewrk3.c	2011-04-04 13:41:41.717791151 -0700
> +++ b/drivers/net/ewrk3.c	2011-04-04 13:46:55.425138028 -0700
> @@ -1604,55 +1604,51 @@ static u32 ewrk3_get_link(struct net_dev
>  	return !(cmr & CMR_LINK);
>  }
>  
> -static int ewrk3_phys_id(struct net_device *dev, u32 data)
> +static int ewrk3_set_phys_id(struct net_device *dev,
> +			     enum ethtool_phys_id_state state)
>  {
>  	struct ewrk3_private *lp = netdev_priv(dev);
>  	unsigned long iobase = dev->base_addr;
>  	unsigned long flags;
>  	u8 cr;
> -	int count;
> -
> -	/* Toggle LED 4x per second */
> -	count = data << 2;
>  
>  	spin_lock_irqsave(&lp->hw_lock, flags);
>  
> -	/* Bail if a PHYS_ID is already in progress */
> -	if (lp->led_mask == 0) {
> -		spin_unlock_irqrestore(&lp->hw_lock, flags);
> -		return -EBUSY;
> -	}
> +	switch (state) {
> +	case ETHTOOL_ID_ACTIVE:
> +		/* Bail if a PHYS_ID is already in progress */
> +		if (lp->led_mask == 0) {
> +			spin_unlock_irqrestore(&lp->hw_lock, flags);
> +			return -EBUSY;
> +		}
[...]

This can never happen.  Well, actually it can with the first version of
my patch, but I'll fix that. :-)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

