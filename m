From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 4/4] Add loopback address type inline
Date: Fri, 06 Apr 2007 12:51:54 +0900 (JST)
Message-ID: <20070406.125154.73441979.yoshfuji@linux-ipv6.org>
References: <11758281872074-git-send-email-brian.haley@hp.com>
	<151538c13022864224f5ff440e1147f884abb492.1175794415.git.brian.haley@hp.com>
	<4615BCBD.2030607@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:40429 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1766920AbXDFDvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 23:51:01 -0400
In-Reply-To: <4615BCBD.2030607@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <4615BCBD.2030607@hp.com> (at Thu, 05 Apr 2007 23:21:33 -0400), Brian Haley <brian.haley@hp.com> says:

> Add loopback address type inline to avoid calls to ipv6_addr_type().

> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index f6aa338..7f1aabe 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -455,8 +455,9 @@ int ip6_forward(struct sk_buff *skb)
>   		 */
>   		if (xrlim_allow(dst, 1*HZ))
>   			ndisc_send_redirect(skb, n, target);
> -	} else if (ipv6_addr_type(&hdr->saddr)&(IPV6_ADDR_MULTICAST|IPV6_ADDR_LOOPBACK
> -						|IPV6_ADDR_LINKLOCAL)) {
> +	} else if (ipv6_addr_type_multicast(&hdr->saddr) ||
> +		   ipv6_addr_loopback(&hdr->saddr) ||
> +		   ipv6_addr_scope_linklocal(&hdr->saddr)) {
>   		/* This check is security critical. */
>   		goto error;
>   	}
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 32c6398..06ee92d 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1067,7 +1067,6 @@ int ip6_route_add(struct fib6_config *cfg)
>   	struct net_device *dev = NULL;
>   	struct inet6_dev *idev = NULL;
>   	struct fib6_table *table;
> -	int addr_type;
> 
>   	if (cfg->fc_dst_len > 128 || cfg->fc_src_len > 128)
>   		return -EINVAL;
> @@ -1108,9 +1107,7 @@ int ip6_route_add(struct fib6_config *cfg)
>   		cfg->fc_protocol = RTPROT_BOOT;
>   	rt->rt6i_protocol = cfg->fc_protocol;
> 
> -	addr_type = ipv6_addr_type(&cfg->fc_dst);
> -
> -	if (addr_type & IPV6_ADDR_MULTICAST)
> +	if (ipv6_addr_type_multicast(&cfg->fc_dst))
>   		rt->u.dst.input = ip6_mc_input;
>   	else
>   		rt->u.dst.input = ip6_forward;

different commit...

--yoshfuji
