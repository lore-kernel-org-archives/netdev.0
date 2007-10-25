From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IFGROUPv4 2/3] Interface group: core (netlink) part
Date: Thu, 25 Oct 2007 17:14:46 +0200
Message-ID: <4720B2E6.1060505@trash.net>
References: <11933245923082-git-send-email-panther@balabit.hu> <11933245922165-git-send-email-panther@balabit.hu> <11933245921874-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Laszlo Attila Toth <panther@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44312 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757206AbXJYPQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 11:16:12 -0400
In-Reply-To: <11933245921874-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laszlo Attila Toth wrote:
> Interface groups let handle different interfaces together
> especially in netfilter modules.
> Modified net device structure and netlink interface.
> 
> @@ -891,6 +895,13 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
>  		}
>  	}
>  
> +	if (tb[IFLA_IFGROUP]) {
> +		write_lock_bh(&dev_base_lock);
> +		dev->ifgroup = nla_get_u32(tb[IFLA_IFGROUP]);
> +		write_unlock_bh(&dev_base_lock);
> +		modified = 1;
> +	}


The locking looks unnecessary, the rtnl should be enough.
I'm not even sure why its used for operstate and linkmode,
AFAICS they are also protected by the rtnl.
