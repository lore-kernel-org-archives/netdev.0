From: "Rami Rosen" <roszenrami@gmail.com>
Subject: Re: [PATCH] [IPv4] Reply net unreachable ICMP message
Date: Thu, 6 Dec 2007 10:12:41 +0200
Message-ID: <b25312890712060012t608bf45at61919643da17876a@mail.gmail.com>
References: <20071206153105.df7d112f.mitch@linux.vnet.ibm.com>
	 <20071206074946.GA2164@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Mitsuru Chinen" <mitch@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, "David Miller" <davem@davemloft.net>
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.191]:36191 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593AbXLFIMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 03:12:44 -0500
Received: by mu-out-0910.google.com with SMTP id i10so525475mue
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2007 00:12:42 -0800 (PST)
In-Reply-To: <20071206074946.GA2164@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Jarek,

I am sorry, but I think I am nor sure I underatand exactly what you mean when
you say:
"It overrides err codes from fib_lookup, where such decisions should be made."

What is incorrect here ?

There are two lines added in this patch;

IP_INC_STATS_BH(IPSTATS_MIB_INNOROUTES);
and err = -ENETUNREACH;

The first one is, regardless to say, not relevant to err codes.

The second, err = -ENETUNREACH, is from: ip_route_input_slow().
(net/ipv4/route.c).

Assigning values to err is done more than once in this method;
for example,
e_hostunreach:
	err = -EHOSTUNREACH;

e_inval:
	err = -EINVAL;

e_nobufs:
	err = -ENOBUFS;

So I don't think anything is incorrect here.


Regards,
Rami Rosen

	


On Dec 6, 2007 9:49 AM, Jarek Poplawski <jarkao2@o2.pl> wrote:
>
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
> >                       break;
> >               case ENETUNREACH:
> >                       code = ICMP_NET_UNREACH;
> > +                     IP_INC_STATS_BH(IPSTATS_MIB_INNOROUTES);
> >                       break;
> >               case EACCES:
> >                       code = ICMP_PKT_FILTERED;
> > @@ -2004,6 +2005,7 @@ no_route:
> >       RT_CACHE_STAT_INC(in_no_route);
> >       spec_dst = inet_select_addr(dev, 0, RT_SCOPE_UNIVERSE);
> >       res.type = RTN_UNREACHABLE;
> > +     err = -ENETUNREACH;
> >       goto local_input;
> >
> >       /*
>
> This patch seems to be wrong. It overrides err codes from
> fib_lookup, where such decisions should be made.
>
> Regards,
> Jarek P.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
