From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 5/8] virtio: convert to net_device_ops
Date: Tue, 06 Jan 2009 09:40:45 +0000
Message-ID: <1231234845.12050.2.camel@localhost.localdomain>
References: <20090105201442.749889072@vyatta.com>
	 <20090105201514.658060465@vyatta.com>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:50555 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751137AbZAFJkw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 04:40:52 -0500
In-Reply-To: <20090105201514.658060465@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-01-05 at 12:14 -0800, Stephen Hemminger wrote:

> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> 
> --- a/drivers/net/virtio_net.c	2009-01-05 11:24:44.578819161 -0800
> +++ b/drivers/net/virtio_net.c	2009-01-05 12:11:17.169569416 -0800
> @@ -624,6 +624,18 @@ static int virtnet_change_mtu(struct net
>  	return 0;
>  }
>  
> +static const struct net_device_ops virtnet_netdev = {
> +	.ndo_open            = virtnet_open,
> +	.ndo_stop   	     = virtnet_close,
> +	.ndo_start_xmit      = start_xmit,
> +	.ndo_validate_addr   = eth_validate_addr,
> +	.ndo_set_mac_address = eth_mac_addr,
> +	.ndo_change_mtu	     = virtnet_change_mtu,
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	.ndo_poll_controller = virtnet_netpoll,
> +#endif
> +};
> +
>  static int virtnet_probe(struct virtio_device *vdev)
>  {
>  	int err;
> @@ -636,14 +648,8 @@ static int virtnet_probe(struct virtio_d
>  		return -ENOMEM;
>  
>  	/* Set up network device as normal. */
> -	dev->open = virtnet_open;
> -	dev->stop = virtnet_close;
> -	dev->hard_start_xmit = start_xmit;
> -	dev->change_mtu = virtnet_change_mtu;
> +	dev->netdev_ops = &virtnet_netdev;
>  	dev->features = NETIF_F_HIGHDMA;
> -#ifdef CONFIG_NET_POLL_CONTROLLER
> -	dev->poll_controller = virtnet_netpoll;
> -#endif

Looks good to me.

Acked-by: Mark McLoughlin <markmc@redhat.com>

Thanks,
Mark.

