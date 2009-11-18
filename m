From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 1/4] net: Add support to netdev ops for changing
	hardware queue MAC and VLAN filters
Date: Wed, 18 Nov 2009 19:53:06 +0000
Message-ID: <1258573987.2780.20.camel@achroite.uk.solarflarecom.com>
References: <20091117214923.15119.98918.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shemminger@vyatta.com, netdev@vger.kernel.org,
	gospo@redhat.com, Mitch Williams <mitch.a.williams@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:20662 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758437AbZKRTxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 14:53:03 -0500
In-Reply-To: <20091117214923.15119.98918.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-11-17 at 13:50 -0800, Jeff Kirsher wrote:
> From: Williams, Mitch A <mitch.a.williams@intel.com>
> 
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  include/linux/netdevice.h |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 7043f85..6a70365 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -610,6 +610,8 @@ struct netdev_queue {
>   *	this function is called when a VLAN id is unregistered.
>   *
>   * void (*ndo_poll_controller)(struct net_device *dev);
> + * int (*ndo_set_queue_mac)(struct net_device *dev, int queue, u8* mac);
> + * int (*ndo_set_queue_vlan)(struct net_device *dev, int queue, u16 vlan);
>   */
>  #define HAVE_NET_DEVICE_OPS
>  struct net_device_ops {
> @@ -659,6 +661,10 @@ struct net_device_ops {
>  #define HAVE_NETDEV_POLL
>  	void                    (*ndo_poll_controller)(struct net_device *dev);
>  #endif
> +	int			(*ndo_set_queue_mac)(struct net_device *dev,
> +						     int queue, u8 *mac);
> +	int			(*ndo_set_queue_vlan)(struct net_device *dev,
> +						      int queue, u16 vlan);
[...]

How do you remove a filter?

What about filtering on both MAC address and VLAN (our new controller
supports that)?

It seems like this could be defined as an extension to the existing
ethtool RX flow filter API.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

