From: David Miller <davem@davemloft.net>
Subject: Re: small RPS cache for fragments?
Date: Tue, 17 May 2011 17:10:00 -0400 (EDT)
Message-ID: <20110517.171000.1166144155994185790.davem@davemloft.net>
References: <BANLkTikyH=q_6uOvFh3_Z_xwPST3zVijZw@mail.gmail.com>
	<20110517.164929.1737248436066795381.davem@davemloft.net>
	<1305666050.2691.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51236 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932296Ab1EQVKE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 17:10:04 -0400
In-Reply-To: <1305666050.2691.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 17 May 2011 23:00:50 +0200

> Le mardi 17 mai 2011 =E0 16:49 -0400, David Miller a =E9crit :
>> From: Tom Herbert <therbert@google.com>
>> Date: Tue, 17 May 2011 13:02:25 -0700
>>=20
>> > I like it!  And this sounds like the sort of algorithm that NICs m=
ight
>> > be able to implement to solve the UDP/RSS unpleasantness, so even
>> > better.
>>=20
>> Actually, I think it won't work.  Even Linux emits fragments last to
>> first, so we won't see the UDP header until the last packet where it=
's
>> no longer useful.
>>=20
>> Back to the drawing board. :-/
>=20
> Well, we could just use the iph->id in the rxhash computation for fra=
gs.
>=20
> At least all frags of a given datagram should be reassembled on same
> cpu, so we get RPS (but not RFS)

That's true, but one could also argue that in the existing code at leas=
t
one of the packets (the one with the UDP header) would make it to the
proper flow cpu.

That could be as much as half of the packets.

So I don't yet see it as a clear win.
