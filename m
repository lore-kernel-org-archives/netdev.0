From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] Enable tx timestamping on loopback and dummy
Date: Sun, 12 Mar 2017 00:17:30 +0100
Message-ID: <13e4b635-089d-fb4b-4d73-62b807bb86e8@hartkopp.net>
References: <20170311144224.GA21305@u480fcf44e5b8574c5490.ant.amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Ezequiel Lara Gomez <ezegomez@amazon.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.220]:29086 "EHLO
        mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751325AbdCKXUk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 18:20:40 -0500
In-Reply-To: <20170311144224.GA21305@u480fcf44e5b8574c5490.ant.amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ezequiel,

On 03/11/2017 03:42 PM, Ezequiel Lara Gomez wrote:
> Also, cleanup some warnings from timestamping code.

in fact you're doing three different things here:

1. introduce tx timestamping
2. silently change an include: <asm/io.h> -> <linux/io.h>
3. fix some whitespace and empty line issues

You'd better provide one patch for 1 & 2 and explain why 2 is needed.

Regards,
Oliver

>
> This enables testing of SO_TIMESTAMPING options by targetting localhost
> addresses.
>
> Tested on qemu using txtimestamping.c from the kernel selftests.
>
> Signed-off-by: Ezequiel Lara Gomez <ezegomez@amazon.com>
> ---
>  drivers/net/dummy.c    |  1 +
>  drivers/net/loopback.c | 14 +++++++-------
>  2 files changed, 8 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
> index 2c80611..32fdc00 100644
> --- a/drivers/net/dummy.c
> +++ b/drivers/net/dummy.c
> @@ -125,6 +125,7 @@ static netdev_tx_t dummy_xmit(struct sk_buff *skb, struct net_device *dev)
>  	dstats->tx_bytes += skb->len;
>  	u64_stats_update_end(&dstats->syncp);
>
> +	skb_tx_timestamp(skb);
>  	dev_kfree_skb(skb);
>  	return NETDEV_TX_OK;
>  }
> diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
> index b23b719..8bcf479 100644
> --- a/drivers/net/loopback.c
> +++ b/drivers/net/loopback.c
> @@ -13,7 +13,7 @@
>   *
>   *		Alan Cox	:	Fixed oddments for NET3.014
>   *		Alan Cox	:	Rejig for NET3.029 snap #3
> - *		Alan Cox	: 	Fixed NET3.029 bugs and sped up
> + *		Alan Cox	:	Fixed NET3.029 bugs and sped up
>   *		Larry McVoy	:	Tiny tweak to double performance
>   *		Alan Cox	:	Backed out LMV's tweak - the linux mm
>   *					can't take it...
> @@ -41,7 +41,7 @@
>  #include <linux/in.h>
>
>  #include <linux/uaccess.h>
> -#include <asm/io.h>
> +#include <linux/io.h>
>
>  #include <linux/inet.h>
>  #include <linux/netdevice.h>
> @@ -74,6 +74,7 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
>  	struct pcpu_lstats *lb_stats;
>  	int len;
>
> +	skb_tx_timestamp(skb);
>  	skb_orphan(skb);
>
>  	/* Before queueing this packet to netif_rx(),
> @@ -149,8 +150,8 @@ static void loopback_dev_free(struct net_device *dev)
>  }
>
>  static const struct net_device_ops loopback_ops = {
> -	.ndo_init      = loopback_dev_init,
> -	.ndo_start_xmit= loopback_xmit,
> +	.ndo_init        = loopback_dev_init,
> +	.ndo_start_xmit  = loopback_xmit,
>  	.ndo_get_stats64 = loopback_get_stats64,
>  	.ndo_set_mac_address = eth_mac_addr,
>  };
> @@ -170,7 +171,7 @@ static void loopback_setup(struct net_device *dev)
>  	dev->priv_flags		|= IFF_LIVE_ADDR_CHANGE | IFF_NO_QUEUE;
>  	netif_keep_dst(dev);
>  	dev->hw_features	= NETIF_F_GSO_SOFTWARE;
> -	dev->features 		= NETIF_F_SG | NETIF_F_FRAGLIST
> +	dev->features		= NETIF_F_SG | NETIF_F_FRAGLIST
>  		| NETIF_F_GSO_SOFTWARE
>  		| NETIF_F_HW_CSUM
>  		| NETIF_F_RXCSUM
> @@ -206,7 +207,6 @@ static __net_init int loopback_net_init(struct net *net)
>  	net->loopback_dev = dev;
>  	return 0;
>
> -
>  out_free_netdev:
>  	free_netdev(dev);
>  out:
> @@ -217,5 +217,5 @@ static __net_init int loopback_net_init(struct net *net)
>
>  /* Registered in net/core/dev.c */
>  struct pernet_operations __net_initdata loopback_net_ops = {
> -       .init = loopback_net_init,
> +	.init = loopback_net_init,
>  };
>
