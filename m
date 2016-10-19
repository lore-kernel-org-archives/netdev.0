From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net-next 6/6] net: use core MTU range checking in misc
 drivers
Date: Wed, 19 Oct 2016 18:05:46 +0200
Message-ID: <20161019160546.GC11224@bistromath.localdomain>
References: <20161019023333.15760-1-jarod@redhat.com>
 <20161019023333.15760-7-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Stefan Richter <stefanr@s5r6.in-berlin.de>,
        Faisal Latif <faisal.latif@intel.com>,
        linux-rdma@vger.kernel.org, Cliff Whickman <cpw@sgi.com>,
        Robin Holt <robinmholt@gmail.com>,
        Jes Sorensen <jes@trained-monkey.org>,
        Marek Lindner <mareklindner@neomailbox.ch>,
        Simon Wunderlich <sw@simonwunderlich.de>,
        Antonio Quartulli <a@unstable.cc>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161019023333.15760-7-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2016-10-18, 22:33:33 -0400, Jarod Wilson wrote:
[...]
> diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
> index 309311b..b5f125c 100644
> --- a/drivers/firewire/net.c
> +++ b/drivers/firewire/net.c
> @@ -1349,15 +1349,6 @@ static netdev_tx_t fwnet_tx(struct sk_buff *skb, struct net_device *net)
>  	return NETDEV_TX_OK;
>  }
>  
> -static int fwnet_change_mtu(struct net_device *net, int new_mtu)
> -{
> -	if (new_mtu < 68)
> -		return -EINVAL;
> -
> -	net->mtu = new_mtu;
> -	return 0;
> -}
> -

This doesn't do any upper bound checking.

>  static const struct ethtool_ops fwnet_ethtool_ops = {
>  	.get_link	= ethtool_op_get_link,
>  };
> @@ -1366,7 +1357,6 @@ static const struct net_device_ops fwnet_netdev_ops = {
>  	.ndo_open       = fwnet_open,
>  	.ndo_stop	= fwnet_stop,
>  	.ndo_start_xmit = fwnet_tx,
> -	.ndo_change_mtu = fwnet_change_mtu,
>  };
>  
>  static void fwnet_init_dev(struct net_device *net)
> @@ -1481,6 +1471,8 @@ static int fwnet_probe(struct fw_unit *unit,
>  	max_mtu = (1 << (card->max_receive + 1))
>  		  - sizeof(struct rfc2734_header) - IEEE1394_GASP_HDR_SIZE;
>  	net->mtu = min(1500U, max_mtu);
> +	net->min_mtu = ETH_MIN_MTU;
> +	net->max_mtu = net->mtu;

But that will now prevent increasing the MTU above the initial value?

-- 
Sabrina
