From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] netdevice: order of synchronization of IFF_PROMISC
 and IFF_ALLMULTI
Date: Mon, 16 Jun 2008 11:27:27 +0200
Message-ID: <485631FF.7040509@trash.net>
References: <48562F9A.5030509@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58001 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759366AbYFPJ1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 05:27:43 -0400
In-Reply-To: <48562F9A.5030509@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> IFF_PROMISC should be set before IFF_ALLMULTI.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> ---
>  net/8021q/vlan_dev.c |   25 +++++++++++++++++++------
>  1 files changed, 19 insertions(+), 6 deletions(-)
> 
> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index 5d055c2..14742e3 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -547,10 +547,14 @@ static int vlan_dev_open(struct net_device *dev)
>  	}
>  	memcpy(vlan->real_dev_addr, real_dev->dev_addr, ETH_ALEN);
>  
> -	if (dev->flags & IFF_ALLMULTI)
> -		dev_set_allmulti(real_dev, 1);
> +	/* NOTE: order of synchronization of IFF_PROMISC and IFF_ALLMULTI
> +	   is important. Some (broken) drivers set IFF_PROMISC, when
> +	   IFF_ALLMULTI is requested not asking us and not reporting.
> +	 */
>  	if (dev->flags & IFF_PROMISC)
>  		dev_set_promiscuity(real_dev, 1);
> +	if (dev->flags & IFF_ALLMULTI)
> +		dev_set_allmulti(real_dev, 1);


What exactly is the problem here? The VLAN code is obviously not
one of the broken drivers, so why should it care what other drivers
do?

