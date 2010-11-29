From: David Miller <davem@davemloft.net>
Subject: Re: Simple kernel attack using socketpair. easy, 100%
 reproductiblle, works under guest. no way to protect :(
Date: Mon, 29 Nov 2010 09:46:28 -0800 (PST)
Message-ID: <20101129.094628.39176431.davem@davemloft.net>
References: <1290672978.2798.151.camel@edumazet-laptop>
	<AANLkTi=NTFXXY42nh+j3xM4n-NTPaz=fWKmAY=MpsHze@mail.gmail.com>
	<1290694299.2858.330.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: socketpair@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50115
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755328Ab0K2RqB convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Nov 2010 12:46:01 -0500
In-Reply-To: <1290694299.2858.330.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 25 Nov 2010 15:11:39 +0100

> [PATCH] af_unix: limit recursion level
>=20
> Its easy to eat all kernel memory and trigger NMI watchdog, using an
> exploit program that queues unix sockets on top of others.
>=20
> lkml ref : http://lkml.org/lkml/2010/11/25/8
>=20
> This mechanism is used in applications, one choice we have is to have=
 a
> recursion limit.
>=20
> Other limits might be needed as well (if we queue other types of file=
s),
> since the passfd mechanism is currently limited by socket receive que=
ue
> sizes only.
>=20
> Add a recursion_level to unix socket, allowing up to 4 levels.
>=20
> Each time we send an unix socket through sendfd mechanism, we copy it=
s
> recursion level (plus one) to receiver. This recursion level is clear=
ed
> when socket receive queue is emptied.
>=20
> Reported-by: =ED=C1=D2=CB =EB=CF=D2=C5=CE=C2=C5=D2=C7 <socketpair@gma=
il.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Ok, since such deep recursive AF_UNIX fd sends is pretty
rediculious, it seems this is not likely to hit legitimate
use cases and thus I've applied this.

Also queued up for -stable.

Thanks!
