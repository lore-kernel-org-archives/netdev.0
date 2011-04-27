From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: disallow bind() to reuse addr/port
Date: Wed, 27 Apr 2011 19:40:14 +0200
Message-ID: <1303926014.3166.101.camel@edumazet-laptop>
References: <1294140172.3579.81.camel@edumazet-laptop>
	 <AANLkTimuNM7vmeR89WKXtrUbJO1Wt1ivp9y=bQvtWg0j@mail.gmail.com>
	 <1294744462.2927.53.camel@edumazet-laptop>
	 <20110111.140336.128591591.davem@davemloft.net>
	 <BANLkTi=176iFKUHn351OWOZUSaUBkgKf2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, daniel.baluta@gmail.com,
	gasparch@gmail.com, netdev@vger.kernel.org
To: "George B." <georgeb@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51345 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756437Ab1D0RkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 13:40:18 -0400
Received: by wya21 with SMTP id 21so1444983wya.19
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 10:40:17 -0700 (PDT)
In-Reply-To: <BANLkTi=176iFKUHn351OWOZUSaUBkgKf2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 27 avril 2011 =C3=A0 10:37 -0700, George B. a =C3=A9crit :
> On Tue, Jan 11, 2011 at 2:03 PM, David Miller <davem@davemloft.net> w=
rote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Tue, 11 Jan 2011 12:14:22 +0100
> >
> >> [PATCH] tcp: disallow bind() to reuse addr/port
> >>
> >> inet_csk_bind_conflict() logic currently disallows a bind() if
> >> it finds a friend socket (a socket bound on same address/port)
> >> satisfying a set of conditions :
> >>
> >> 1) Current (to be bound) socket doesnt have sk_reuse set
> >> OR
> >> 2) other socket doesnt have sk_reuse set
> >> OR
> >> 3) other socket is in LISTEN state
> >>
> >> We should add the CLOSE state in the 3) condition, in order to avo=
id two
> >> REUSEADDR sockets in CLOSE state with same local address/port, sin=
ce
> >> this can deny further operations.
> >>
> >> Note : a prior patch tried to address the problem in a different (=
and
> >> buggy) way. (commit fda48a0d7a8412ced tcp: bind() fix when many po=
rts
> >> are bound).
> >>
> >> Reported-by: Gaspar Chilingarov <gasparch@gmail.com>
> >> Reported-by: Daniel Baluta <daniel.baluta@gmail.com>
> >> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> >
> > Applied, thanks.
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
>=20
> OK, just saw this, so please disregard my earlier.

Hmm... you'll discover this patch was reverted, because it broke some
applications.

So your problem remains.



