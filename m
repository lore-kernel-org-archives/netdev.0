From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: Re: [PATCH] [IPv4] Reply net unreachable ICMP message
Date: Thu, 6 Dec 2007 17:14:21 +0900
Message-ID: <20071206171421.1495c019.mitch@linux.vnet.ibm.com>
References: <20071206153105.df7d112f.mitch@linux.vnet.ibm.com>
	<20071206074946.GA2164@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:49799 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751226AbXLFIOq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2007 03:14:46 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lB68Ehfo022260
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 03:14:43 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB68EhW5124886
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 03:14:43 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB68EgVl005826
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 03:14:43 -0500
In-Reply-To: <20071206074946.GA2164@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 6 Dec 2007 08:49:47 +0100
Jarek Poplawski <jarkao2@o2.pl> wrote:

> On 06-12-2007 07:31, Mitsuru Chinen wrote:
> > IPv4 stack doesn't reply any ICMP destination unreachable message
> > with net unreachable code when IP detagrams are being discarded
> > because of no route could be found in the forwarding path.
> > Incidentally, IPv6 stack replies such ICMPv6 message in the similar
> > situation.
> > 
> > Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
> > ---
> >  net/ipv4/route.c |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> > 
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > index 6714bbc..ba85ec9 100644
> > --- a/net/ipv4/route.c
> > +++ b/net/ipv4/route.c
> > @@ -1375,6 +1375,7 @@ static int ip_error(struct sk_buff *skb)
> >  			break;
> >  		case ENETUNREACH:
> >  			code = ICMP_NET_UNREACH;
> > +			IP_INC_STATS_BH(IPSTATS_MIB_INNOROUTES);
> >  			break;
> >  		case EACCES:
> >  			code = ICMP_PKT_FILTERED;
> > @@ -2004,6 +2005,7 @@ no_route:
> >  	RT_CACHE_STAT_INC(in_no_route);
> >  	spec_dst = inet_select_addr(dev, 0, RT_SCOPE_UNIVERSE);
> >  	res.type = RTN_UNREACHABLE;
> > +	err = -ENETUNREACH;
> >  	goto local_input;
> >  
> >  	/*
> 
> This patch seems to be wrong. It overrides err codes from
> fib_lookup, where such decisions should be made.

fib_lookup() replies -ESRCH in this situation.
It is necessary to override the variable by the suitable error
number like the code under e_hostunreach label.

Best Regards,
----
Mitsuru Chinen <mitch@linux.vnet.ibm.com>
