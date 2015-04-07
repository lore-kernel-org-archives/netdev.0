From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 4/4] udp_tunnel: Pass UDP socket down through
 udp_tunnel{,6}_xmit_skb().
Date: Tue, 07 Apr 2015 21:14:20 +0200
Message-ID: <1428434060.1373881.250400989.21CC8071@webmail.messagingengine.com>
References: <20150405.221909.1825232827861250716.davem@davemloft.net>
 <CALx6S35rK35GFZAcqygjGNRUhC=vJx60TYLFDUeUd2bAim7Vzg@mail.gmail.com>
 <1428421534.2928.3.camel@stressinduktion.org>
 <CALx6S37vo+9mDJKnkOhJXjArDLDju7hw4N5_Ggoir_U-OqmdAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, pablo@netfilter.org,
	=?UTF-8?Q?Ji=C5=99=C3=AD=20P=C3=ADrko?= <jiri@resnulli.us>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CALx6S37vo+9mDJKnkOhJXjArDLDju7hw4N5_Ggoir_U-OqmdAw@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 7, 2015, at 20:56, Tom Herbert wrote:
> On Tue, Apr 7, 2015 at 8:45 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
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
> Actually, for consistency amongst all the IP encapsulation protocols
> and given Dave's comments on how this is supposed to work, maybe for
> the v4 and v6 tunnels we could have a raw AF_INET{6} socket opened for
> all the tunnels to use when ip_tunnel_xmit is called. If it makes a
> difference for UDP encapsulation, a UDP socket could also be opened.

Yes, agreed.

Currently the semantics seem fine to me. vxlan needs this because it is
communicating via multicast addresses and thus we depend on correct
mc_loop behaviour. Which other tunnel protocols could be affected by
this, too?
