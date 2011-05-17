From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: small RPS cache for fragments?
Date: Tue, 17 May 2011 23:27:42 +0200
Message-ID: <1305667662.2691.7.camel@edumazet-laptop>
References: <BANLkTikyH=q_6uOvFh3_Z_xwPST3zVijZw@mail.gmail.com>
	 <20110517.164929.1737248436066795381.davem@davemloft.net>
	 <1305666050.2691.4.camel@edumazet-laptop>
	 <20110517.171000.1166144155994185790.davem@davemloft.net>
	 <1305666822.2848.51.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40868 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932269Ab1EQV1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 17:27:45 -0400
Received: by wya21 with SMTP id 21so737726wya.19
        for <netdev@vger.kernel.org>; Tue, 17 May 2011 14:27:44 -0700 (PDT)
In-Reply-To: <1305666822.2848.51.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 17 mai 2011 =C3=A0 22:13 +0100, Ben Hutchings a =C3=A9crit :
> On Tue, 2011-05-17 at 17:10 -0400, David Miller wrote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Tue, 17 May 2011 23:00:50 +0200
> >=20
> > > Le mardi 17 mai 2011 =C3=A0 16:49 -0400, David Miller a =C3=A9cri=
t :
> > >> From: Tom Herbert <therbert@google.com>
> > >> Date: Tue, 17 May 2011 13:02:25 -0700
> > >>=20
> > >> > I like it!  And this sounds like the sort of algorithm that NI=
Cs might
> > >> > be able to implement to solve the UDP/RSS unpleasantness, so e=
ven
> > >> > better.
> > >>=20
> > >> Actually, I think it won't work.  Even Linux emits fragments las=
t to
> > >> first, so we won't see the UDP header until the last packet wher=
e it's
> > >> no longer useful.
> > >>=20
> > >> Back to the drawing board. :-/
> > >=20
> > > Well, we could just use the iph->id in the rxhash computation for=
 frags.
> > >=20
> > > At least all frags of a given datagram should be reassembled on s=
ame
> > > cpu, so we get RPS (but not RFS)
> >=20
> > That's true, but one could also argue that in the existing code at =
least
> > one of the packets (the one with the UDP header) would make it to t=
he
> > proper flow cpu.
>=20
> No, we ignore the layer-4 header when either MF or OFFSET is non-zero=
=2E

Exactly

As is, RPS (based on our software rxhash computation) should be working
fine with frags, unless we receive different flows with same
(src_addr,dst_addr) pair.

This is why I asked David if real workloads could hit one cpu instead o=
f
many ones.



