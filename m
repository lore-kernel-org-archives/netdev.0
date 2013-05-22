From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] bridge: Set vlan_features to allow offloads on vlans.
Date: Wed, 22 May 2013 17:12:44 +0100
Message-ID: <1369239164.2670.13.camel@bwh-desktop.uk.level5networks.com>
References: <1369237590-29871-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <bridge@lists.linux-foundation.org>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:42964 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755417Ab3EVQMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 12:12:48 -0400
In-Reply-To: <1369237590-29871-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-22 at 11:46 -0400, Vlad Yasevich wrote:
> When vlan device is configured on top of the brige, it does
> not support any offload capabilities because the bridge
> device does not initiliaze vlan_fatures.  Set vlan_fatures to
> be equivalent to hw_fatures.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  net/bridge/br_device.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
> index 9673128..126f2c2 100644
> --- a/net/bridge/br_device.c
> +++ b/net/bridge/br_device.c
> @@ -352,6 +352,7 @@ void br_dev_setup(struct net_device *dev)
>  	dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
>  			   NETIF_F_GSO_MASK | NETIF_F_HW_CSUM |
>  			   NETIF_F_HW_VLAN_CTAG_TX;
> +	dev->vlan_features = dev->hw_features;

I think you need to mask out NETIF_F_HW_VLAN_CTAG_TX (although maybe the
vlan driver should take care of that itself).

Ben.

>  	br->dev = dev;
>  	spin_lock_init(&br->lock);

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
