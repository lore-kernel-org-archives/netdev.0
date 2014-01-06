From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next v4] IPv6: use anycast addresses as source addresses in echo reply
Date: Mon, 6 Jan 2014 02:41:41 -0800 (PST)
Message-ID: <1389004901.29746.YahooMailBasic@web125506.mail.ne1.yahoo.com>
References: <20140105230505.GA29910@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm33.bullet.mail.ne1.yahoo.com ([98.138.229.26]:33126 "HELO
	nm33.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752672AbaAFKo1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 05:44:27 -0500
In-Reply-To: <20140105230505.GA29910@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 1/5/14, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> On Fri, Jan 03, 2014 at 05:43:31PM +0100, Francois-Xavier Le Bail wrote:
> > diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
> > index 5d42009..65c8619 100644
> > --- a/net/ipv6/icmp.c
> > +++ b/net/ipv6/icmp.c
> > @@ -556,7 +556,9 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
> >  
> >  	saddr = &ipv6_hdr(skb)->daddr;
> >  
> > -	if (!ipv6_unicast_destination(skb))
> > +	if (!ipv6_unicast_destination(skb) &&
> > +	    !(net->ipv6.anycast_src_echo_reply &&
> > +	      ipv6_chk_acast_addr(net, NULL, saddr)))
> >  		saddr = NULL;

> I am not sure why you left out the device at ipv6_chk_acast_addr?

> IMHO this logic is a bit more complex, we can pass NULL for ipv6 addresses of
> scope global but need to check the interface for scope link.

> It is already possible via setsockopt JOIN_ANYCAST that an ll address is
> anycast on another interface which may not be checked here.

In this case, there are neighbor solicitations "who has LL anycast" with no reply, so no echo request is sent.

Do you find some problem testing my patch ?

BR
