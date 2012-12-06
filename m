From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 1/1] vlan: restore offload use on vlan transmit
Date: Thu, 6 Dec 2012 23:43:47 +0000
Message-ID: <1354837427.2828.88.camel@bwh-desktop.uk.solarflarecom.com>
References: <1354827296-12009-1-git-send-email-gallatin@myri.com>
	 <1354827296-12009-2-git-send-email-gallatin@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:47560 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716Ab2LFXnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 18:43:50 -0500
In-Reply-To: <1354827296-12009-2-git-send-email-gallatin@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-06 at 15:54 -0500, Andrew Gallatin wrote:
> This patch copies the vlan device's dev->features to its
> dev->vlan_features, which allows packets to arrive at
> vlan_dev_hard_start_xmit() with their offloads intact.
> 
> When a packet destined for a vlan interface is transmitted, it passes
> through dev_hard_start_xmit() (and netif_skb_features()) twice.  First
> on its way to vlan_dev_hard_start_xmit(), and then again on its way to
> the backing device's xmit handler. If the vlan device does not setup
> its dev->vlan_features, then netif_skb_features() will strip the
> features on the first trip through it (on the way to
> vlan_dev_hard_start_xmit()).
> 
> Signed-off-by: Andrew Gallatin <gallatin@myri.com>
> ---
>  net/8021q/vlan_dev.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index 4a6d31a..9d4b3c9 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -559,6 +559,7 @@ static int vlan_dev_init(struct net_device *dev)
>  
>  	dev->features |= real_dev->vlan_features | NETIF_F_LLTX;
>  	dev->gso_max_size = real_dev->gso_max_size;
> +	dev->vlan_features = dev->features;

To repeat myself: no, this will result in the features being transferred
to VLAN devices stacked on top of this one (to an arbitrary depth!).

Ben.

>  	/* ipv6 shared card related stuff */
>  	dev->dev_id = real_dev->dev_id;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
