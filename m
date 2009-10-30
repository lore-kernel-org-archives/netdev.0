From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: set carrier off in probe
Date: Thu, 29 Oct 2009 20:09:05 -0700
Message-ID: <20091029200905.00f4c13d@nehalam>
References: <20091029235807.GF3228@jenkins.home.ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brandon Philips <bphilips@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59052 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752351AbZJ3DJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 23:09:13 -0400
In-Reply-To: <20091029235807.GF3228@jenkins.home.ifup.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Oct 2009 16:58:07 -0700
Brandon Philips <bphilips@suse.de> wrote:

> Before bringing up a sky2 interface up ethtool reports 
> "Link detected: yes". Do as ixgbe does and netif_carrier_off() on
> probe().
> 
> Signed-off-by: Brandon Philips <bphilips@suse.de>
> 
> ---
>  drivers/net/sky2.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> Index: linux-2.6/drivers/net/sky2.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/sky2.c
> +++ linux-2.6/drivers/net/sky2.c
> @@ -4538,6 +4538,8 @@ static int __devinit sky2_probe(struct p
>  		goto err_out_free_netdev;
>  	}
>  
> +	netif_carrier_off(dev);
> +
>  	netif_napi_add(dev, &hw->napi, sky2_poll, NAPI_WEIGHT);
>  
>  	err = request_irq(pdev->irq, sky2_intr,

IMHO carrier is meaningless until device is up? What software
cares?

-- 
