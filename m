From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Patch net] net: allow setting mac address of loopback device
Date: Thu, 30 Jan 2014 15:42:48 +0100
Message-ID: <20140130144248.GE25336@order.stressinduktion.org>
References: <1391038731-7501-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46941 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752572AbaA3Omt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 09:42:49 -0500
Content-Disposition: inline
In-Reply-To: <1391038731-7501-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 29, 2014 at 03:38:51PM -0800, Cong Wang wrote:
> We are trying to mirror the local traffic from lo to eth0,
> allowing setting mac address of lo to eth0 would make
> the ether addresses in these packets correct, so that
> we don't have to modify the ether header again.
> 
> Since usually no one cares about its mac address (all-zero),
> it is safe to allow those who care to set its mac address.
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> 
> ---
> diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
> index c5011e0..a0ee030 100644
> --- a/drivers/net/loopback.c
> +++ b/drivers/net/loopback.c
> @@ -160,6 +160,7 @@ static const struct net_device_ops loopback_ops = {
>  	.ndo_init      = loopback_dev_init,
>  	.ndo_start_xmit= loopback_xmit,
>  	.ndo_get_stats64 = loopback_get_stats64,
> +	.ndo_set_mac_address = eth_mac_addr,
>  };

IFF_LIVE_ADDR_CHANGE would also be helpful to change mac address if loopback
is already up.

Also I doubt this is a change for net but for net-next.

Greetings,

  Hannes
