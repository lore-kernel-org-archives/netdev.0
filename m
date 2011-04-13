From: Cyril =?utf-8?q?Bont=C3=A9?= <cyril.bonte@free.fr>
Subject: Re: [Bugme-new] [Bug 32832] New: shutdown(2) does not fully shut down socket any more
Date: Wed, 13 Apr 2011 09:06:19 +0200
Message-ID: <201104130906.19882.cyril.bonte@free.fr>
References: <bug-32832-10286@https.bugzilla.kernel.org/> <20110412.161744.27803776.davem@davemloft.net> <1302663327.2811.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, kees@outflux.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:45153 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756156Ab1DMHGb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 03:06:31 -0400
In-Reply-To: <1302663327.2811.55.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 13 avril 2011 04:55:27, Eric Dumazet a =C3=A9crit :
> I worked on it this week end to discover FreeBSD 8.1 would not allow
> several CLOSE sockets bound to same port even with REUSEADDR.

Just to complete the information, yes it does, but only after a shutdow=
n()=20
call. And this is the use case of haproxy, amavisd (quoted in the bugzi=
lla bug=20
report), and others.

> So haproxy claim is a bit wrong (its trick doesnt work on FreeBSD), a=
nd
> used an undocumented linux feature.

Both test cases (the one I provided to explain the haproxy issue and th=
e one=20
provided by Kees) are not about binding 2 sockets at the same time but =
binding=20
a new socket after the first one has been shutdown.
Sadly this also looks undocumented on FreeBSD (only saw a reference on =
it in a=20
code comment).

> Since SO_REUSEPORT is not a 'stable fix', I suggest we revert the pat=
ch,
> and eventually work on SO_REUSEPORT on net-next-2.6
>=20
> What do you think ?

Agree.

Many thanks for the time you already spent on that.
