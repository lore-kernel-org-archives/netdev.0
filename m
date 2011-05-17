From: Rick Jones <rick.jones2@hp.com>
Subject: Re: small RPS cache for fragments?
Date: Tue, 17 May 2011 14:11:37 -0700
Message-ID: <1305666697.8149.951.camel@tardy>
References: <20110517.143342.1566027350038182221.davem@davemloft.net>
	 <BANLkTikyH=q_6uOvFh3_Z_xwPST3zVijZw@mail.gmail.com>
	 <20110517.164929.1737248436066795381.davem@davemloft.net>
	 <1305666050.2691.4.camel@edumazet-laptop>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:48623 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932296Ab1EQVLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 17:11:40 -0400
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
>=20
> At least all frags of a given datagram should be reassembled on same
> cpu, so we get RPS (but not RFS)

Won't that just scatter the fragments of a given flow across processors=
?
Instead of then going back and forth between two caches - where
reassembly happens and then where the app is running, it will go back
and forth between the app's cache and pretty much nearly every other
cache in the system (or at least configured to take RPS traffic).

rick

