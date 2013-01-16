From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 4/7] net/mlx4_en: Set carrier to off when a
 port is stopped
Date: Wed, 16 Jan 2013 16:00:16 +0000
Message-ID: <1358352016.2923.15.camel@bwh-desktop.uk.solarflarecom.com>
References: <1358350935-3281-1-git-send-email-amirv@mellanox.com>
	 <1358350935-3281-5-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:64898 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756742Ab3APQAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 11:00:20 -0500
In-Reply-To: <1358350935-3281-5-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-16 at 17:42 +0200, Amir Vadai wrote:
> From: Eugenia Emantayev <eugenia@mellanox.com>
> 
> Under heavy CPU load changing ring size/mtu/etc. could result in transmit
> timeout, since stop-start port might take more than 10 sec. Set
> netif_carrier_off to prevent tx queue transmit timeout.

A spurious link change can restart L3 auto-configuration (DHCP, SLAAC,
etc.)  netif_device_detach() also inhibits the watchdog and doesn't have
that problem.

Ben.

> Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index 805e242..108c4cf 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -1212,6 +1212,7 @@ void mlx4_en_stop_port(struct net_device *dev)
>  
>  	/* Synchronize with tx routine */
>  	netif_tx_lock_bh(dev);
> +	netif_carrier_off(dev);
>  	netif_tx_stop_all_queues(dev);
>  	netif_tx_unlock_bh(dev);
>  

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
