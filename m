From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 7/9] [ETH]: Start net device with carrier down
Date: Wed, 24 Sep 2008 14:32:03 -0700
Message-ID: <20080924143203.1eba6bbe@extreme>
References: <e665d9ff8b50796ce65c503604453056217bfc8a.1221537369.git.tpiepho@freescale.com>
	<ebb4b9e34a594b9ca0fda9042bfa12bff9e9fac2.1221537369.git.tpiepho@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Trent Piepho <tpiepho@freescale.com>,
	Andy Fleming <afleming@freescale.com>
To: Trent Piepho <tpiepho@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45739 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751517AbYIXVcH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 17:32:07 -0400
In-Reply-To: <ebb4b9e34a594b9ca0fda9042bfa12bff9e9fac2.1221537369.git.tpiepho@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Sep 2008 14:20:55 -0700
Trent Piepho <tpiepho@freescale.com> wrote:

> Because it _is_ down when the device starts.
> 
> The device's carrier status is controlled via the functions
> netif_carrier_on() and netif_carrier_off().  These set or clear a bit
> indicating the lower level link aka carrier is down, and if the state
> changed, they fire off a routing netlink event.
> 
> The problem is that when the device is first created and opened, the state
> bit indicating the carrier is down isn't set, i.e. the state is wrong.
> When the carrier comes up for the first time no netlink event is sent,
> since the device state indicated the carrier was already up.
> 
> Signed-off-by: Trent Piepho <tpiepho@freescale.com>
> CC: Andy Fleming <afleming@freescale.com>
> ---
>  net/ethernet/eth.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
> index a80839b..cdba6d0 100644
> --- a/net/ethernet/eth.c
> +++ b/net/ethernet/eth.c
> @@ -333,6 +333,7 @@ void ether_setup(struct net_device *dev)
>  	dev->addr_len		= ETH_ALEN;
>  	dev->tx_queue_len	= 1000;	/* Ethernet wants good queues */
>  	dev->flags		= IFF_BROADCAST|IFF_MULTICAST;
> +	dev->state		= 1 << __LINK_STATE_NOCARRIER;
>  
>  	memset(dev->broadcast, 0xFF, ETH_ALEN);
>  

This breaks devices that never call netif_carrier_on.

Standard practice is to call netif_carrier_off after allocation but before
register_netdev
