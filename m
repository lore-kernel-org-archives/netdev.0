From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 4/4] udp_tunnel: Pass UDP socket down through
 udp_tunnel{,6}_xmit_skb().
Date: Wed, 08 Apr 2015 01:24:59 +0200
Message-ID: <1428449099.869458.250499317.11121567@webmail.messagingengine.com>
References: <20150405.221909.1825232827861250716.davem@davemloft.net>
 <CALx6S35rK35GFZAcqygjGNRUhC=vJx60TYLFDUeUd2bAim7Vzg@mail.gmail.com>
 <1428421534.2928.3.camel@stressinduktion.org>
 <20150407.153044.772260953305341361.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, pablo@netfilter.org,
	jiri@resnulli.us
To: David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:54659 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932898AbbDGXZB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 19:25:01 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 9B27420934
	for <netdev@vger.kernel.org>; Tue,  7 Apr 2015 19:24:55 -0400 (EDT)
In-Reply-To: <20150407.153044.772260953305341361.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Apr 7, 2015, at 21:30, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Tue, 07 Apr 2015 17:45:34 +0200
> 
> > On Mo, 2015-04-06 at 23:02 -0700, Tom Herbert wrote:
> >> On Sun, Apr 5, 2015 at 7:19 PM, David Miller <davem@davemloft.net> wrote:
> >> > diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
> >> > index b6a211a..5cafd92 100644
> >> > --- a/net/ipv6/ip6_tunnel.c
> >> > +++ b/net/ipv6/ip6_tunnel.c
> >> > @@ -1100,7 +1100,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
> >> >         ipv6h->nexthdr = proto;
> >> >         ipv6h->saddr = fl6->saddr;
> >> >         ipv6h->daddr = fl6->daddr;
> >> > -       ip6tunnel_xmit(skb, dev);
> >> > +       ip6tunnel_xmit(NULL, skb, dev);
> >> 
> >> By same should logic iptunnel_xmit call in ip_tunnel_xmit should take
> >> NULL arg for socket?
> > 
> > Sure!
> > 
> > Thanks, otherwise the patches look good!
> > 
> > Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> Ok I've made this adjustment and will push the series out, thanks
> everyone.

There is one small problem which already was present before this patch
because of my change b6a7719aedd7e5 ("ipv4: hash net ptr into
fragmentation bucket selection"). It uses sock_net in iptunnel_xmit,
which causes a NULL ptr panic. This patchset did make it more visible
because of the explicit NULL passing but the bug was introduced by my
patch.

Just wanted to let you know if reports are coming in - I fix it up
tomorrow. I will also explore the possibility to give each tunnel at
least a raw socket, what Tom proposed.

Rick Jones identified this, thanks!

Bye,
Hannes
