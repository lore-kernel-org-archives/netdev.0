From: David Miller <davem@davemloft.net>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Thu, 28 Aug 2008 00:57:41 -0700 (PDT)
Message-ID: <20080828.005741.97382742.davem@davemloft.net>
References: <48B643C3.9040502@cosmosbay.com>
	<20080827.235158.187658055.davem@davemloft.net>
	<48B65009.5040805@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, andi@firstfloor.org, davej@redhat.com,
	netdev@vger.kernel.org, j.w.r.degoede@hhs.nl
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46587
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754672AbYH1H5q convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Aug 2008 03:57:46 -0400
In-Reply-To: <48B65009.5040805@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 28 Aug 2008 09:13:13 +0200

> David Miller a =E9crit :
> > We could not define a reasonable way to trigger hash table growth.
> > GC attempts to keep a resident set of entries in the cache, and the=
se
> > heuristics are guided by the table size itself.  So if you grow the
> > table too aggressively this never has a chance to work.
>=20
> Maybe because of overcomplicated algos in net/ipv4/route.c, and
> mixing "number of entries in cache", and "hash table size" things...

But it is exactly what we want to use to create equilabrium
when the size is large enough.

> Fact is that nobody wants to have eight elements per hash bucket,
> especially in case of DDOS.

Of this there is no doubt.  But also, nobody wants to use 1GB hash
table simply because of poorly implemented interactions between GC and
hash table growth :-)

> > You want to respond dynamically to traffic in a reasonable amount o=
f
> > time, but you don't want to get tricked by bursts of RCU effects.
> >=20
>=20
> Right, but we also use process context processing instead of plain
> timer soft irq things, so at least RCU effects should now be OK.

I meant to say "bursts or RCU effects".

> > We never came up with an algorithm that addresses all of these
> > issues.
>=20
> Could you give us the pointer to your previous work ?

It was a series of patches I started posting in August 2006:

	http://marc.info/?l=3Dlinux-netdev&m=3D115510979129323&w=3D2

There was a bunch of discussion, the locking and synchronization
were worked out but the resize logic was not.
