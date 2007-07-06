From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: -ENOCOMPILE
Date: Fri, 06 Jul 2007 08:57:17 -0400
Message-ID: <468E3C2D.30107@hp.com>
References: <20070705.173742.104701626.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:52638 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760449AbXGFM5X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 08:57:23 -0400
In-Reply-To: <20070705.173742.104701626.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index f96ed76..6496e03 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2472,6 +2472,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
>  		write_unlock_bh(&idev->lock);
>  
>  		__ipv6_ifa_notify(RTM_DELADDR, ifa);
> +		atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifp);
                                                                         ^^^^^^^

Shit.   How did that thing sneak back in there.. should be 'ifa'

Yes, I cut and pasted, compiled... failed... fixed... tested...  Still
have that kernel running by the way.

looking...
arghhhh, wrong branch!!!  <blowing it away>

I'll resubmit and you can sit on as long as you want.

-vlad


>  		in6_ifa_put(ifa);
>  
>  		write_lock_bh(&idev->lock);
> 

