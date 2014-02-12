From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Patch net-next v2] net: allow setting mac address of loopback
 device
Date: Wed, 12 Feb 2014 06:50:28 -0500
Message-ID: <20140212115028.GA4038@hmsreliant.think-freely.org>
References: <1392168086-25607-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50825 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752253AbaBLLuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 06:50:44 -0500
Content-Disposition: inline
In-Reply-To: <1392168086-25607-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 11, 2014 at 05:21:26PM -0800, Cong Wang wrote:
> We are trying to mirror the local traffic from lo to eth0,
> allowing setting mac address of lo to eth0 would make
> the ether addresses in these packets correct, so that
> we don't have to modify the ether header again.
> 
> Since usually no one cares about its mac address (all-zero),
> it is safe to allow those who care to set its mac address.
> 
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>

> ---
> diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
> index c5011e0..e7c1d5f 100644
> --- a/drivers/net/loopback.c
> +++ b/drivers/net/loopback.c
> @@ -160,6 +160,7 @@ static const struct net_device_ops loopback_ops = {
>  	.ndo_init      = loopback_dev_init,
>  	.ndo_start_xmit= loopback_xmit,
>  	.ndo_get_stats64 = loopback_get_stats64,
> +	.ndo_set_mac_address = eth_mac_addr,
>  };
>  
>  /*
> @@ -174,6 +175,7 @@ static void loopback_setup(struct net_device *dev)
>  	dev->tx_queue_len	= 0;
>  	dev->type		= ARPHRD_LOOPBACK;	/* 0x0001*/
>  	dev->flags		= IFF_LOOPBACK;
> +	dev->priv_flags		|= IFF_LIVE_ADDR_CHANGE;
>  	dev->priv_flags	       &= ~IFF_XMIT_DST_RELEASE;
>  	dev->hw_features	= NETIF_F_ALL_TSO | NETIF_F_UFO;
>  	dev->features 		= NETIF_F_SG | NETIF_F_FRAGLIST
> 
