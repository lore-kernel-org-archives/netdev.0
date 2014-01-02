From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2] IPv6: add option to use Subnet-Router anycast addresses as source addresses
Date: Fri, 3 Jan 2014 00:17:30 +0100
Message-ID: <20140102231730.GH22494@order.stressinduktion.org>
References: <1388688977.95873.YahooMailBasic@web125502.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: =?utf-8?Q?Fran=C3=A7ois-Xavier?= Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36146 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258AbaABXRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 18:17:31 -0500
Content-Disposition: inline
In-Reply-To: <1388688977.95873.YahooMailBasic@web125502.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 02, 2014 at 10:56:17AM -0800, Fran=C3=A7ois-Xavier Le Bail =
wrote:
> > I wouldn't actually add this knob, we can just enable that by defau=
lt.
>=20
> I think we need to keep by default the existing behaviour (ICMPv6 ech=
o reply with unicast)
> in case some setups use it, and use "enable_anycast_src" to change th=
e behaviour=20
> according to RFC4942.

We try to extract the destination address and reuse it in the reply. Th=
e
other system should not notice if it communicates with a unicast or
anycast address. Am I missing something?

> > Also it should be no problem to bind() to those addresses.
> =20
> > I am still unsure what to do with a bind to any or if the address m=
ust be
> > bound specifically (maybe that is worth a knob).
>=20
> > In the long term I would like to see that we can add additional any=
cast
> > addresses via iproute:
> =20
> > ip -6 a a 1234::1/64 dev eth0 anycast
> =20
> > or something like that. That should be rather easy, as in just incr=
ementing
> > the anycast counter for an interface in inet6_rtm_newaddr
> > and adding a flag to ifa_flags which gets passed down by iproute2.
> =20
> > I'll do some research on if this should also get integrated with so=
urce address selection.
>=20
> It can be the objects of future evolutions.
> I have to think about these.

Me, too. :) I don't know what the consequences are if we make the whole
unicast path agnostic to anycast. It could very well be a bad idea.

Thanks,

  Hannes
