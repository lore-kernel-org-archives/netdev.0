From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] ipv6: Do cleanup for ip_mr_init
Date: Wed, 02 Jul 2008 18:18:31 +0900 (JST)
Message-ID: <20080702.181831.32808810.yoshfuji@linux-ipv6.org>
References: <48606D1B.3040507@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:36001 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754355AbYGBJR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 05:17:28 -0400
In-Reply-To: <48606D1B.3040507@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <48606D1B.3040507@cn.fujitsu.com> (at Tue, 24 Jun 2008 11:42:19 +0800), Wang Chen <wangchen@cn.fujitsu.com> says:

> If do not do it, we will get following issues:
> 1. Leaving junks after inet6_init failing halfway.
> 2. Leaving proc and notifier junks after ipv6 modules unloading.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

> diff --git a/include/linux/mroute6.h b/include/linux/mroute6.h
> index e798959..05ffaac 100644
> --- a/include/linux/mroute6.h
> +++ b/include/linux/mroute6.h
> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> index e84b3fd..15d4138 100644
> --- a/net/ipv6/af_inet6.c
> +++ b/net/ipv6/af_inet6.c
> @@ -1115,7 +1118,9 @@ static void __exit inet6_exit(void)
>  	ipv6_netfilter_fini();
>  	igmp6_cleanup();
>  	ndisc_cleanup();
> +#ifdef CONFIG_IPV6_MROUTE
>  	icmpv6_cleanup();
> +#endif
>  	rawv6_exit();
>  
>  	unregister_pernet_subsys(&inet6_net_ops);

Well we really need this #ifdef ... #endif?

And well, would you please make ip6_mr_init() return
error and handle it correctly?

We need to fix ipv4-side as well.

--yoshfuji
