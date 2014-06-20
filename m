From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Patch net-next] veth: add netpoll support
Date: Fri, 20 Jun 2014 15:29:21 -0400
Message-ID: <20140620192921.GA18996@hmsreliant.think-freely.org>
References: <1403291878-4199-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, s.priebe@profihost.ag,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45951 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904AbaFTT3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 15:29:31 -0400
Content-Disposition: inline
In-Reply-To: <1403291878-4199-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 20, 2014 at 12:17:58PM -0700, Cong Wang wrote:
> It is trivial to add netpoll support to veth, since
> it is not stacked device, we don't need to setup and cleanup
> netpoll.
> 
> Reported-by: Stefan Priebe <s.priebe@profihost.ag>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> 
> ---
> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index b4a10bc..03e781b 100644
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -248,6 +248,13 @@ static void veth_dev_free(struct net_device *dev)
>  	free_netdev(dev);
>  }
>  
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +static void veth_poll_controller(struct net_device *dev)
> +{
> +	return;
> +}
> +#endif	/* CONFIG_NET_POLL_CONTROLLER */
> +
>  static const struct net_device_ops veth_netdev_ops = {
>  	.ndo_init            = veth_dev_init,
>  	.ndo_open            = veth_open,
> @@ -257,6 +264,9 @@ static const struct net_device_ops veth_netdev_ops = {
>  	.ndo_get_stats64     = veth_get_stats64,
>  	.ndo_set_rx_mode     = veth_set_multicast_list,
>  	.ndo_set_mac_address = eth_mac_addr,
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	.ndo_poll_controller	= veth_poll_controller,
> +#endif
>  };
>  
>  #define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_ALL_TSO |    \
> 

Maybe add a comment to the function (like in the tun/tap driver to indicate why
you have a function that only returns there, and why thats importatn.

Otherwise
Acked-by: Neil Horman <nhorman@tuxdriver.com>
