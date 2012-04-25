From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: RTAX_FEATURE_ALLFRAG causes inefficient
 TCP segment sizing
Date: Wed, 25 Apr 2012 07:32:40 +0200
Message-ID: <1335331960.5205.180.camel@edumazet-glaptop>
References: <1335289058.5205.165.camel@edumazet-glaptop>
	 <CANP3RGd0mV8RcH1zCLBg+N9sgPGbiynhOSfoUAYpcMgYsvzeNA@mail.gmail.com>
	 <1335298228.5205.168.camel@edumazet-glaptop>
	 <CANP3RGfhc+4FjB152r58AP66oZQmj0oY-Zh=9qNn9OABCXPwbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tore Anderson <tore@fud.no>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:53332 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754065Ab2DYFcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 01:32:45 -0400
Received: by wejx9 with SMTP id x9so872272wej.19
        for <netdev@vger.kernel.org>; Tue, 24 Apr 2012 22:32:44 -0700 (PDT)
In-Reply-To: <CANP3RGfhc+4FjB152r58AP66oZQmj0oY-Zh=9qNn9OABCXPwbw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-24 at 14:50 -0700, Maciej =C5=BBenczykowski wrote:
> On Tue, Apr 24, 2012 at 1:10 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > On Tue, 2012-04-24 at 12:49 -0700, Maciej =C5=BBenczykowski wrote:
> >> Why do we refuse to set ipv6 mtu's below 1280?
> >> how is what we do any better?
> >
> > I guess you didnt read Tore use case.
> >
> > Thats the standard : http://tools.ietf.org/html/rfc2460#section-5
> >
> >   In response to an IPv6 packet that is sent to an IPv4 destination
> >   (i.e., a packet that undergoes translation from IPv6 to IPv4), th=
e
> >   originating IPv6 node may receive an ICMP Packet Too Big message
> >   reporting a Next-Hop MTU less than 1280.  In that case, the IPv6 =
node
> >   is not required to reduce the size of subsequent packets to less =
than
>=20
> ... is not required to reduce...
>=20
> but doesn't that mean it _may_ reduce anyway?
> and thus make life easier on the guy who will have to fragment (and
> thus he won't have to fragment).
>=20
> [of course you'd still need to lose 8 bytes for the frag header...]
>=20
> >   1280, but must include a Fragment header in those packets so that=
 the
> >   IPv6-to-IPv4 translating router can obtain a suitable Identificat=
ion
> >   value to use in resulting IPv4 fragments.  Note that this means t=
he
> >   payload may have to be reduced to 1232 octets (1280 minus 40 for =
the
> >   IPv6 header and 8 for the Fragment header), and smaller still if
> >   additional extension headers are used.
>=20
> I just don't see what not decreasing mtu below 1280 buys us.

But we chose to _not_ decrease mtu and adhere to the specs.

Current linux chose to implement the allfragfeature, so match RFC 2460
specs.

If you want to reduce size of subsequent packets, its a lot more work i=
n
linux stack, for small gain, if any.

We only need to properly generate the fragment header, that means
reducing the _payload_ by 8 bytes. Not reducing the _mtu_ that still is
1280, as allowed.

IPv6 must cohabit with IPv4 for the next years, there is no hope
thinking it can ignore tunnelings issues, since tunneling is part of th=
e
global IPv6 transition that is currently happening.
