From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: small RPS cache for fragments?
Date: Tue, 17 May 2011 22:13:42 +0100
Message-ID: <1305666822.2848.51.camel@bwh-desktop>
References: <BANLkTikyH=q_6uOvFh3_Z_xwPST3zVijZw@mail.gmail.com>
	 <20110517.164929.1737248436066795381.davem@davemloft.net>
	 <1305666050.2691.4.camel@edumazet-laptop>
	 <20110517.171000.1166144155994185790.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:5627 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932296Ab1EQVNp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 17:13:45 -0400
In-Reply-To: <20110517.171000.1166144155994185790.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-17 at 17:10 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 17 May 2011 23:00:50 +0200
>=20
> > Le mardi 17 mai 2011 =C3=A0 16:49 -0400, David Miller a =C3=A9crit =
:
> >> From: Tom Herbert <therbert@google.com>
> >> Date: Tue, 17 May 2011 13:02:25 -0700
> >>=20
> >> > I like it!  And this sounds like the sort of algorithm that NICs=
 might
> >> > be able to implement to solve the UDP/RSS unpleasantness, so eve=
n
> >> > better.
> >>=20
> >> Actually, I think it won't work.  Even Linux emits fragments last =
to
> >> first, so we won't see the UDP header until the last packet where =
it's
> >> no longer useful.
> >>=20
> >> Back to the drawing board. :-/
> >=20
> > Well, we could just use the iph->id in the rxhash computation for f=
rags.
> >=20
> > At least all frags of a given datagram should be reassembled on sam=
e
> > cpu, so we get RPS (but not RFS)
>=20
> That's true, but one could also argue that in the existing code at le=
ast
> one of the packets (the one with the UDP header) would make it to the
> proper flow cpu.

No, we ignore the layer-4 header when either MF or OFFSET is non-zero.

Ben.

> That could be as much as half of the packets.
>=20
> So I don't yet see it as a clear win.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

