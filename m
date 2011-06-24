From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC][NET-NEXT PATCH 2/2] net: Add GSO to vlan_features
 initialization
Date: Fri, 24 Jun 2011 17:51:42 +0100
Message-ID: <1308934302.3034.4.camel@bwh-desktop>
References: <4E0406BE.50900@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	"therbert@google.com" <therbert@google.com>
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:55294 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271Ab1FXQvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 12:51:46 -0400
In-Reply-To: <4E0406BE.50900@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-06-24 at 11:38 +0800, Shan Wei wrote:
> This patch is not a bug fix.
> Just add GSO to vlan_features initialization, and update comments.
> 
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> ---
>  net/core/dev.c |    9 +++++----
>  1 files changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 6b6ef14..becc1e5 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5478,11 +5478,12 @@ int register_netdevice(struct net_device *dev)
>  		dev->features |= NETIF_F_NOCACHE_COPY;
>  	}
>  
> -	/* Enable GRO and NETIF_F_HIGHDMA for vlans by default,
> -	 * vlan_dev_init() will do the dev->features check, so these features
> -	 * are enabled only if supported by underlying device.
> +	/* Enable GSO, GRO and NETIF_F_HIGHDMA for vlans by default,
> +	 * vlan_dev_fix_features() will do the features check,
> +	 * so NETIF_F_HIGHDMA feature is enabled only if supported
> +	 * by underlying device.
>  	 */
> -	dev->vlan_features |= (NETIF_F_GRO | NETIF_F_HIGHDMA);
> +	dev->vlan_features |= (NETIF_F_SOFT_FEATURES | NETIF_F_HIGHDMA);
>  
>  	ret = call_netdevice_notifiers(NETDEV_POST_INIT, dev);
>  	ret = notifier_to_errno(ret);

Have you verified that GSO works correctly for VLAN devices if the
underlying device does not support VLAN tag insertion?
skb_gso_segment() has code to handle this case, but I suspect it's not
actually being exercised at the moment.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

