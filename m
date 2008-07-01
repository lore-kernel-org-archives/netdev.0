From: Patrick McHardy <kaber@trash.net>
Subject: Re: v2 [PATCH net-next 5/7] ipv4: Check return of dev_set_allmulti
Date: Tue, 01 Jul 2008 11:40:16 +0200
Message-ID: <4869FB80.8050107@trash.net>
References: <4869A251.108@cn.fujitsu.com> <4869A42A.2010009@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63230 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbYGAJkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 05:40:18 -0400
In-Reply-To: <4869A42A.2010009@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> allmulti might overflow.
> Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
> dev_set_promiscuity/allmulti return error number if overflow happened.
> 
> Here, we check the positive increment for allmulti to get error return.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> ---
>  net/ipv4/ipmr.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> index 11700a4..ba0280f 100644
> --- a/net/ipv4/ipmr.c
> +++ b/net/ipv4/ipmr.c
> @@ -398,6 +398,7 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
>  	struct vif_device *v = &vif_table[vifi];
>  	struct net_device *dev;
>  	struct in_device *in_dev;
> +	int err;
>  
>  	/* Is vif busy ? */
>  	if (VIF_EXISTS(vifi))
> @@ -435,7 +436,9 @@ static int vif_add(struct vifctl *vifc, int mrtsock)
>  	if ((in_dev = __in_dev_get_rtnl(dev)) == NULL)
>  		return -EADDRNOTAVAIL;
>  	IPV4_DEVCONF(in_dev->cnf, MC_FORWARDING)++;
> -	dev_set_allmulti(dev, +1);
> +	err = dev_set_allmulti(dev, 1);
> +	if (err)
> +		return err;

Missing error handling for VIFF_REGISTER and VIFF_TUNNEL case.


