From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: small RPS cache for fragments?
Date: Tue, 17 May 2011 22:11:43 +0100
Message-ID: <1305666703.2848.49.camel@bwh-desktop>
References: <20110517.143342.1566027350038182221.davem@davemloft.net>
	 <BANLkTikyH=q_6uOvFh3_Z_xwPST3zVijZw@mail.gmail.com>
	 <20110517.164929.1737248436066795381.davem@davemloft.net>
	 <1305666050.2691.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:5407 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932318Ab1EQVLr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 17:11:47 -0400
In-Reply-To: <1305666050.2691.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-17 at 23:00 +0200, Eric Dumazet wrote:
> Le mardi 17 mai 2011 =C3=A0 16:49 -0400, David Miller a =C3=A9crit :
> > From: Tom Herbert <therbert@google.com>
> > Date: Tue, 17 May 2011 13:02:25 -0700
> >=20
> > > I like it!  And this sounds like the sort of algorithm that NICs =
might
> > > be able to implement to solve the UDP/RSS unpleasantness, so even
> > > better.
> >=20
> > Actually, I think it won't work.  Even Linux emits fragments last t=
o
> > first, so we won't see the UDP header until the last packet where i=
t's
> > no longer useful.
> >=20
> > Back to the drawing board. :-/
>=20
> Well, we could just use the iph->id in the rxhash computation for fra=
gs.

But then each datagram lands on a different CPU, and reordering is
liable to happen far more often than it does now.

> At least all frags of a given datagram should be reassembled on same
> cpu, so we get RPS (but not RFS)

You could still do RPS with just IP addresses (same as RSS using
Toeplitz hashes).

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

