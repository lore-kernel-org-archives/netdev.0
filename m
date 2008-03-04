From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [patch 06/12][NETNS][IPV6] route6 - make route6 per namespace
Date: Wed, 05 Mar 2008 08:02:25 +0900 (JST)
Message-ID: <20080305.080225.41277542.yoshfuji@linux-ipv6.org>
References: <20080304210326.169013927@mai.toulouse-stg.fr.ibm.com>
	<20080304211023.817913201@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	benjamin.thery@bull.net, yoshfuji@linux-ipv6.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:53729 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765541AbYCDXBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 18:01:22 -0500
In-Reply-To: <20080304211023.817913201@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080304211023.817913201@mai.toulouse-stg.fr.ibm.com> (at Tue, 04 Mar 2008 22:03:32 +0100), Daniel Lezcano <dlezcano@fr.ibm.com> says:

> This patch makes the routing engine use the network namespaces
> to access routing informations:
> Add a network namespace parameter to ipv6_route_ioctl and 
> propagate the network namespace value to all the routing code
> that have not yet been changed.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
> ---
>  include/net/ip6_route.h |    4 +
>  net/ipv6/af_inet6.c     |    3 -
>  net/ipv6/route.c        |   98 ++++++++++++++++++++++++------------------------
>  3 files changed, 54 insertions(+), 51 deletions(-)
> 
:
> @@ -2544,6 +2545,7 @@ static void ip6_route_net_exit(struct ne
>  	proc_net_remove(net, "ipv6_route");
>  	proc_net_remove(net, "rt6_stats");
>  #endif
> +	rt6_ifdown(net, NULL);
>  }
>  
>  static struct pernet_operations ip6_route_net_ops = {
> @@ -2592,7 +2594,6 @@ fib6_rules_init:
>  xfrm6_init:
>  	xfrm6_fini();
>  out_fib6_init:
> -	rt6_ifdown(&init_net, NULL);
>  	fib6_gc_cleanup();
>  out_kmem_cache:
>  	kmem_cache_destroy(ip6_dst_ops.kmem_cachep);

Please do not change the calling path here.

--yoshfuji
