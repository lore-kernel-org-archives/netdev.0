From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] macvlan: fix netdev feature propagation from lower
 device
Date: Wed, 25 Dec 2013 11:30:36 +0000
Message-ID: <1387971036.26981.2.camel@deadeye.wl.decadent.org.uk>
References: <1387843469-31866-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "Michael S. Tsirkin" <mst@redhat.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30515 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813Ab3LYLaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Dec 2013 06:30:39 -0500
In-Reply-To: <1387843469-31866-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-24 at 01:04 +0100, Florian Westphal wrote:
[...]
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
[...]
> @@ -1010,7 +1021,12 @@ static int macvlan_device_event(struct notifier_block *unused,
>  		break;
>  	case NETDEV_FEAT_CHANGE:
>  		list_for_each_entry(vlan, &port->vlans, list) {
> -			vlan->dev->features = dev->features & MACVLAN_FEATURES;
> +			/* macvlan_fix_features will re-test current vlan
> +			 * features vs. lowerdev features.
> +			 */
> +			vlan->dev->features =
> +				macvlan_fix_features(vlan->dev,
> +						     vlan->dev->features);

You must call netdev_update_features() here and not set
net_device::features directly.

Ben.

>  			vlan->dev->gso_max_size = dev->gso_max_size;
>  			netdev_features_change(vlan->dev);
>  		}

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
