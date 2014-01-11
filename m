From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] IPv6: enable TCP to use an anycast address
Date: Sat, 11 Jan 2014 15:26:59 +0100
Message-ID: <20140111142659.GA6586@order.stressinduktion.org>
References: <CAMrnHh6pBYMLn+zsR2P_oo8KufJq7Dkjm-cSq2N2Hi638yrUog@mail.gmail.com> <1389445570.24657.YahooMailBasic@web125502.mail.ne1.yahoo.com> <CAMrnHh76D1d_JrXhtz+nvJP+Aiux2iPW+5uVZqQpbmWbQG0=OQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?Q?Fran=C3=A7ois-Xavier?= Le Bail <fx.lebail@yahoo.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56452 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbaAKO1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jan 2014 09:27:01 -0500
Content-Disposition: inline
In-Reply-To: <CAMrnHh76D1d_JrXhtz+nvJP+Aiux2iPW+5uVZqQpbmWbQG0=OQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Sat, Jan 11, 2014 at 05:38:27PM +0400, Alexey Kuznetsov wrote:
> On Sat, Jan 11, 2014 at 5:06 PM, Fran=C3=A7ois-Xavier Le Bail
> <fx.lebail@yahoo.com> wrote:
> > Many DNS root-servers use TCP with anycast (IPv4 and IPV6).
> >
> > see : http://tools.ietf.org/html/draft-jabley-dnsop-anycast-mapping=
-04#section-4
> >
> > "   L-Root service is provided using a single IPv4 address (199.7.8=
3.42)
> >    and a single IPv6 address (2001:500:3::42).  It should be noted =
that
> >    it is preferable to refer to the service using its DNS name (L.R=
OOT-
> >    SERVERS.NET) rather than literal addresses, since addresses can
> >    change from time to time."
>=20
> Is this all? It looks like this implies routing by deep packet inspec=
tion,
> fetching some creepy node identification options from inside DNS payl=
oad
> (not written directly, but  implied). This smells funky.
>=20
> Actually, I was alerted by reset processing in your patch, it cannot =
be right.
>=20
> Do not you think this must not be enabled for common use? At least
> some separate sysctl disabled by default.

RFC 4291 - IP Version 6 Addressing Architecture started to allow the us=
e of
anycast addresses as source addresses.

This would be great to have DNS servers listening on them but they need=
 to
respond to both, UDP and TCP.

The idea I had, was, that if a socket does knowingly bind to an anycast
address, it is allowed to do so and process queries on it with both TCP=
 and
UDP. I don't think we need a sysctl for that? Anycast addresses are eit=
her
pre-defined (e.g. the subnet router anycast address) or specified by a =
flag
when the administrator adds one. Currently one can only add anycast add=
resses
either by forwarding and gets the per-subnet anycast address or with a
setsockopt IPV6_JOIN_ANYCAST.

So the problem is what should be allowed when the socket listens on an =
any
address? Maybe this should be protected by a sysctl?

Greetings,

  Hannes
