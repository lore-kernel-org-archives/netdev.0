From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: don't call addrconf_dst_alloc again when enable lo
Date: Fri, 3 Jan 2014 07:53:49 +0100
Message-ID: <20140103065349.GK22494@order.stressinduktion.org>
References: <1371352470-3226-1-git-send-email-gaofeng@cn.fujitsu.com> <20130619.230532.1329281330568271336.davem@davemloft.net> <20131231035718.GB27636@order.stressinduktion.org> <52C4FDBE.5030607@huawei.com> <20140102065429.GB22494@order.stressinduktion.org> <52C51C1E.9040603@huawei.com> <20140102082325.GC22494@order.stressinduktion.org> <52C5325B.8020900@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, gaofeng@cn.fujitsu.com,
	kumaran.4353@gmail.com, netdev@vger.kernel.org
To: chenweilong <chenweilong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36708 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907AbaACGyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 01:54:03 -0500
Content-Disposition: inline
In-Reply-To: <52C5325B.8020900@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 02, 2014 at 05:33:15PM +0800, chenweilong wrote:
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 62d1799..d2f8c0a 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2422,8 +2422,9 @@ static void init_loopback(struct net_device *dev)
>  			if (sp_ifa->flags & (IFA_F_DADFAILED | IFA_F_TENTATIVE))
>  				continue;
> 
> -			if (sp_ifa->rt)
> -				continue;
> +			if (sp_ifa->rt && sp_ifa->rt->dst.dev == dev) {
> +				ip6_del_rt(sp_ifa->rt);
> +			}
> 
>  			sp_rt = addrconf_dst_alloc(idev, &sp_ifa->addr, 0);
> 

Maybe this change would not be that bad after all, as those ifa attached dsts
are already dead and queued up for gc and should not get inserted back.

I'll try to just disable routes without removing them at all when we set an
interface to down at the weekend.
