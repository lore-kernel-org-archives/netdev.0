From: Wilco Baan Hofman <wilco@baanhofman.nl>
Subject: Re: ECMP ipv6 vs ipv4
Date: Mon, 15 Apr 2013 18:53:36 +0200
Message-ID: <1366044816.4975.27.camel@localhost>
References: <1366012728.4975.13.camel@localhost>
	 <516C2212.4030502@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 37-251-2-65.FTTH.ispfabriek.nl ([37.251.2.65]:32834 "EHLO
	mail.baanhofman.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753113Ab3DOQxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 12:53:49 -0400
In-Reply-To: <516C2212.4030502@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-15 at 17:51 +0200, Nicolas Dichtel wrote:
> Le 15/04/2013 09:58, Wilco Baan Hofman a =C3=A9crit :
> > Hi,
> >
> > I'm working on a patch to implement 'nexthop weight' for multipath =
ipv6.
> > However, the ECMPv6 implementation has a few flaws that are quite
> > annoying.
> >
> > One of the flaws is that the netlink nexthop API is asymmetrical, y=
ou
> > can add nexthops through the netlink API, but when the result is
> > requested it is completely different, resulting in bird6 removing t=
he
> > route as it does not match the initial route set.
> In fact, there is two ways to add ECMP routes:
> $ ip -6 route add 3ffe:304:124:2306::/64 \
> 	nexthop via fe80::230:1bff:feb4:e05c dev eth0 \
> 	nexthop via fe80::230:1bff:feb4:dd4f dev eth0
> or
> $ ip -6 route add 3ffe:304:124:2306::/64 via fe80::230:1bff:feb4:dd4f=
 dev
> eth0
> $ ip -6 route append 3ffe:304:124:2306::/64 via fe80::230:1bff:feb4:e=
05c dev
> eth0

> Note that the second way matchs what is returned by the kernel (ie on=
e entry per=20
> nexthop).

Sure, but how do we add nexthop weights and algorithm selection (hash,
random) to this API? I personally prefer to have the routing behaviour
of ipv4 and ipv6 to be as similar as possible, as the basics are the
same anyway.

> >
> > Another one of the flaws is that if I add nexthop weight or algorit=
hm
> > (weighted hash or weighted random) I need to add this to the main r=
t
> > node, this seems like an inefficient memory structure, as this need=
s to
> > be added to all the siblings as well.
> Nexthop weight (rtnh->rtnh_hops) is not implemented.

Yes it is... in my tree, but I want to extend it to also include suppor=
t
for algorithm for hash based, etc.. and to keep it as close to the
existing APIs as possible I think the nexthop structure makes the most
sense for this.

> >
> > I propose that we have a nexthop structure to an exclusive route,
> > similar what we have for IPv4, where we store the gateway, device a=
nd
> > weight for all nexthops and the algorithm in the route. This would =
make
> > the netlink API symmetrical again and fixes the n*n inefficiencies =
when
> > adding routes (all siblings need to know about all siblings).
> >
> > What are your thoughts on this?
> >
This stands :)

-- Wilco
