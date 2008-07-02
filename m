From: Patrick McHardy <kaber@trash.net>
Subject: Re: v3 [PATCH net-next 4/7] ipv6: Check return of dev_set_allmulti
Date: Wed, 02 Jul 2008 14:54:21 +0200
Message-ID: <486B7A7D.2020700@trash.net>
References: <4869A251.108@cn.fujitsu.com> <4869A3EF.60403@cn.fujitsu.com> <4869FB47.6080502@trash.net> <486B3996.8000201@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36623 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbYGBMyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 08:54:23 -0400
In-Reply-To: <486B3996.8000201@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> v2->v3:
>   Do unwind job when error happen.
> 
> diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
> index 1479618..ba763b8 100644
> --- a/net/ipv6/ip6mr.c
> +++ b/net/ipv6/ip6mr.c
> @@ -461,6 +461,13 @@ failure:
>  	unregister_netdevice(dev);
>  	return NULL;
>  }
> +
> +static void ip6mr_unreg_vif(struct net_device *dev)
> +{
> +	dev_close(dev);
> +	unregister_netdevice(dev);

dev_close is already performed by unregister_netdevice.

> +	free_netdev(dev);

This is a double free, the device uses free_netdev as destructor.
