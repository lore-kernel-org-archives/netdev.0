From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at
 000000000000002c
Date: Thu, 02 Feb 2012 16:04:15 +0100
Message-ID: <1328195055.2279.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4F26E72E.2020007@profihost.ag>
		<20120130.164828.1695146432151008554.davem@davemloft.net>
		<4F27A18F.3060907@profihost.ag>
	 <20120201.162157.880976652659067010.davem@davemloft.net>
	 <4F2A87B0.6070900@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, greg@kroah.com,
	jwboyer@gmail.com, hch@infradead.org, netdev@vger.kernel.org,
	david@fromorbit.com, stable@vger.kernel.org, gregkh@suse.de
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57175 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604Ab2BBPEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 10:04:20 -0500
In-Reply-To: <4F2A87B0.6070900@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 f=C3=A9vrier 2012 =C3=A0 13:55 +0100, Stefan Priebe - Profi=
host AG a
=C3=A9crit :
> > Such a non-trivial backport has the danger of adding as many bugs a=
s
> > it is intended to fix.
> >=20
> > Therefore I will not be attempting to make this fix feasible for
> > 3.0.x-stable, sorry.
> >=20
> > I seriously suggest that if you really are hitting this race (the
> > exposure is very small, it only happens if you get redirects and
> > redirects are not common for most hosts) that you move to a more
> > recent kernel such as 3.1.x or 3.2.x, both of which have all the
> > dependencies as well as the bug fix applied.
>=20
> I fully understand that - i'm seeing this bug 2-3 times a week while
> running a bunch of > 1000 servers.
>=20
> I don't want to go to 3.1 or 3.2 as they're not long term.
>=20


Hmm, thats a problem, we need a stable 3.0 kernel for sure.

Should distros handle this tricky problem themselves ?

I tried to find a solution, but we had so many changes in this part of
the code that its really hard.

I see 3 ways :

1) Warn the world 3.0 is unfixable and should be avoided.
   Ask stable team to instead support 3.1 or 3.2

2) Disable redirects on 3.0

3) Maybe try to revert f39925dbde77

(ipv4: Cache learned redirect information in inetpeer.)

Unfortunately this was introduced in 2.6.39, and it seems trying to
revert it on 3.0 tree is not trivial.


David, what do you think ?
