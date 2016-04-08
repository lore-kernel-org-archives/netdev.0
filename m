From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] tuntap: restore default qdisc
Date: Fri, 8 Apr 2016 10:47:57 +0300
Message-ID: <20160408104751-mutt-send-email-mst@redhat.com>
References: <1460093208-4364-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Phil Sutter <phil@nwl.cc>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43368 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757858AbcDHHsB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2016 03:48:01 -0400
Content-Disposition: inline
In-Reply-To: <1460093208-4364-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 08, 2016 at 01:26:48PM +0800, Jason Wang wrote:
> After commit f84bb1eac027 ("net: fix IFF_NO_QUEUE for drivers using
> alloc_netdev"), default qdisc was changed to noqueue because
> tuntap does not set tx_queue_len during .setup(). This patch restores
> default qdisc by setting tx_queue_len in tun_setup().
> 
> Fixes: f84bb1eac027 ("net: fix IFF_NO_QUEUE for drivers using alloc_netdev")
> Cc: Phil Sutter <phil@nwl.cc>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/tun.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 510e90a..2c9e45f5 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1015,7 +1015,6 @@ static void tun_net_init(struct net_device *dev)
>  		/* Zero header length */
>  		dev->type = ARPHRD_NONE;
>  		dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
> -		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
>  		break;
>  
>  	case IFF_TAP:
> @@ -1027,7 +1026,6 @@ static void tun_net_init(struct net_device *dev)
>  
>  		eth_hw_addr_random(dev);
>  
> -		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
>  		break;
>  	}
>  }
> @@ -1481,6 +1479,8 @@ static void tun_setup(struct net_device *dev)
>  
>  	dev->ethtool_ops = &tun_ethtool_ops;
>  	dev->destructor = tun_free_netdev;
> +	/* We prefer our own queue length */
> +	dev->tx_queue_len = TUN_READQ_SIZE;
>  }
>  
>  /* Trivial set of netlink ops to allow deleting tun or tap
> -- 
> 2.5.0
