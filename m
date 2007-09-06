From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1/1] netcore: minor cleanup for register_netdevice
Date: Thu, 06 Sep 2007 14:34:02 +0900 (JST)
Message-ID: <20070906.143402.07329837.yoshfuji@linux-ipv6.org>
References: <46DF8FBC.20106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ellre923@gmail.com, yoshfuji@linux-ipv6.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:40668 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbXIFFci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 01:32:38 -0400
In-Reply-To: <46DF8FBC.20106@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I disagree.  Some of "dev->init()" functions set up dev->iflink;
e.g., ipip_tunnel_init() etc.

In article <46DF8FBC.20106@cn.fujitsu.com> (at Thu, 06 Sep 2007 13:27:24 +0800), FNST-Wang Chen <wangchen@cn.fujitsu.com> says:

> - minor logic cleanup
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> 
> diff -Nurp linux-2.6.22.4.org/net/core/dev.c  linux-2.6.22.4/net/core/dev.c
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
