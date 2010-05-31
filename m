From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: [PATCH] IPv6: fix Mobile IPv6 regression
Date: Mon, 31 May 2010 10:46:20 +0200
Message-ID: <20100531084620.GB1929@jolsa.lab.eng.brq.redhat.com>
References: <87zkzmppfg.fsf@small.ssi.corp>
 <4BFDC14F.6050407@hp.com>
 <8739xdqsuz.fsf@small.ssi.corp>
 <4BFECA65.7030102@hp.com>
 <4BFEE49C.8060301@lucent.com>
 <87hblss92x.fsf@small.ssi.corp>
 <4C00047D.3010404@hp.com>
 <4C0008C7.7020302@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Arnaud Ebalard <arno@natisbad.org>,
	Scott C Otto <otts@alcatel-lucent.com>,
	YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57756 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756495Ab0EaIrT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 May 2010 04:47:19 -0400
Content-Disposition: inline
In-Reply-To: <4C0008C7.7020302@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 28, 2010 at 02:17:43PM -0400, Brian Haley wrote:
> Commit f4f914b5 (net: ipv6 bind to device issue) caused
> a regression with Mobile IPv6 when it changed the meaning
> of fl->oif to become a strict requirement of the route
> lookup.  Instead, only force strict mode when
> sk->sk_bound_dev_if is set on the calling socket, getting
> the intended behavior and fixing the regression.
> 
> Tested-by: Arnaud Ebalard <arno@natisbad.org>
> Signed-off-by: Brian Haley <brian.haley@hp.com>
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 294cbe8..252d761 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -814,7 +814,7 @@ struct dst_entry * ip6_route_output(struct net *net, struct sock *sk,
>  {
>  	int flags = 0;
>  
> -	if (fl->oif || rt6_need_strict(&fl->fl6_dst))
> +	if ((sk && sk->sk_bound_dev_if) || rt6_need_strict(&fl->fl6_dst))
>  		flags |= RT6_LOOKUP_F_IFACE;
>  
>  	if (!ipv6_addr_any(&fl->fl6_src))
hi,

sorry for the late reply, I was out last week..

the change looks ok, I'll verify it with the reproducer
I used for the last fix

thanks,
jirka
