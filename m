From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 1/1] netcore: minor cleanup for register_netdevice
Date: Thu, 6 Sep 2007 11:07:00 +0530
Message-ID: <OFE502ECD4.F0A24663-ON6525734E.001EAF78-6525734E.001EDAAF@in.ibm.com>
References: <46DF8FBC.20106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Wang Chen <ellre923@gmail.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: FNST-Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from E23SMTP03.au.ibm.com ([202.81.18.172]:46381 "EHLO
	e23smtp03.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751905AbXIFFf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 01:35:26 -0400
In-Reply-To: <46DF8FBC.20106@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some init handlers set iflink, and hence it is required. See tunnel init
routines (ipip_tunnel_init), macvlan_init(), etc

netdev-owner@vger.kernel.org wrote on 09/06/2007 10:57:24 AM:

> - minor logic cleanup
>
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
>
> diff -Nurp linux-2.6.22.4.org/net/core/dev.c  linux-2.6.22.4
/net/core/dev.c
> --- linux-2.6.22.4.org/net/core/dev.c    2007-08-22 15:33:40.000000000
> +0800
> +++ linux-2.6.22.4/net/core/dev.c    2007-09-06 13:27:35.000000000 +0800
> @@ -3075,8 +3075,6 @@ int register_netdevice(struct net_device
>     dev->xmit_lock_owner = -1;
>     spin_lock_init(&dev->ingress_lock);
>
> -    dev->iflink = -1;
> -
>     /* Init, if this function is available */
>     if (dev->init) {
>         ret = dev->init(dev);
> @@ -3093,8 +3091,7 @@ int register_netdevice(struct net_device
>     }
>
>     dev->ifindex = dev_new_index();
> -    if (dev->iflink == -1)
> -        dev->iflink = dev->ifindex;
> +    dev->iflink = dev->ifindex;
>
>     /* Check for existence of name */
>     head = dev_name_hash(dev->name);
>
>
>
>
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

