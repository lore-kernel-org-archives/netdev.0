From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3 net-next] net: introduce dev_set_forwarding()
Date: Sat, 2 Nov 2013 15:46:16 +0000
Message-ID: <1383407176.2764.17.camel@deadeye.wl.decadent.org.uk>
References: <20131029090849.GC5944@cpaasch-mac>
	 <1383051962.5464.25.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029.194446.2215574000648693370.davem@davemloft.net>
	 <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
	 <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	<christoph.paasch@uclouvain.be>, <herbert@gondor.apana.org.au>,
	<netdev@vger.kernel.org>, <hkchu@google.com>, <mwdalton@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:33479 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854Ab3KBPqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 11:46:24 -0400
In-Reply-To: <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-11-02 at 07:01 -0700, Eric Dumazet wrote:
[...]
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
[...]
> -void dev_disable_lro(struct net_device *dev)
> +void dev_set_forwarding(struct net_device *dev, int inc)
>  {
>  	/*
> -	 * If we're trying to disable lro on a vlan device
> +	 * If we're trying to enable forwarding from a vlan device
>  	 * use the underlying physical device instead
>  	 */
>  	if (is_vlan_dev(dev))
>  		dev = vlan_dev_real_dev(dev);
>  
> -	dev->wanted_features &= ~NETIF_F_LRO;
> +	dev->forwarding_count += inc;
> +	if (dev->forwarding_count)
> +		dev->wanted_features &= ~NETIF_F_LRO;
> +	else
> +		dev->wanted_features |= NETIF_F_LRO;
>  	netdev_update_features(dev);
[...]

We should not change dev->wanted_features any more.  It should only be
set as requested by userland.

Instead, netdev_update_features() should mask out NETIF_F_LRO based on
dev->forwarding_count.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
