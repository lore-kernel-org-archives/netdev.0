From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] vlan: allow TSO setting on vlan interfaces
Date: Wed, 07 Jul 2010 18:25:11 +0100
Message-ID: <1278523511.2080.3.camel@achroite.uk.solarflarecom.com>
References: <1278522874.5906.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:47085 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394Ab0GGRZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jul 2010 13:25:14 -0400
In-Reply-To: <1278522874.5906.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-07-07 at 19:14 +0200, Eric Dumazet wrote:
> When we need to shape traffic with low speeds, we need to disable tso on
> network interface :
> 
> ethtool -K eth0.2240 tso off
> 
> It seems vlan interfaces miss the set_tso() ethtool method.
> Propagating tso changes from lower device is not always wanted, some
> vlan want TSO on, other want TSO off.

But it should not be possible to enable TSO if the underlying device
doesn't support it.

Ben.

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> 
> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index c6456cb..d827c2e 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -844,6 +844,7 @@ static const struct ethtool_ops vlan_ethtool_ops = {
>  	.get_link		= ethtool_op_get_link,
>  	.get_rx_csum		= vlan_ethtool_get_rx_csum,
>  	.get_flags		= vlan_ethtool_get_flags,
> +	.set_tso		= ethtool_op_set_tso,
>  };
>  
>  static const struct net_device_ops vlan_netdev_ops = {
> 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

