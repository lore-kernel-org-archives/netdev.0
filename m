From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: disallow bind() to reuse addr/port
Date: Wed, 27 Apr 2011 20:02:32 +0200
Message-ID: <1303927352.3166.125.camel@edumazet-laptop>
References: <1294140172.3579.81.camel@edumazet-laptop>
	 <AANLkTimuNM7vmeR89WKXtrUbJO1Wt1ivp9y=bQvtWg0j@mail.gmail.com>
	 <1294744462.2927.53.camel@edumazet-laptop>
	 <20110111.140336.128591591.davem@davemloft.net>
	 <BANLkTi=176iFKUHn351OWOZUSaUBkgKf2Q@mail.gmail.com>
	 <1303926014.3166.101.camel@edumazet-laptop>
	 <BANLkTin-KhU0KqSuUpbCi2STnnxszO5x=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, daniel.baluta@gmail.com,
	gasparch@gmail.com, netdev@vger.kernel.org
To: "George B." <georgeb@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37593 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753773Ab1D0SCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 14:02:38 -0400
Received: by wya21 with SMTP id 21so1459794wya.19
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 11:02:37 -0700 (PDT)
In-Reply-To: <BANLkTin-KhU0KqSuUpbCi2STnnxszO5x=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 27 avril 2011 =C3=A0 10:54 -0700, George B. a =C3=A9crit :
> >>
> >> OK, just saw this, so please disregard my earlier.
> >
> > Hmm... you'll discover this patch was reverted, because it broke so=
me
> > applications.
> >
> > So your problem remains.
>=20
> Just to clarify, both the previous patch from last year *AND* this
> patch in January were reverted?  I can't seem to find anything showin=
g
> the new one being reverted and am now confused.

Yes, all patches were reverted.

Last revert was very recent : 3e8c806a08c7beecd972e7ce15c

http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commit;h=3D3e8c806a08c7beecd972e7ce15c570b9aba64baa

Revert "tcp: disallow bind() to reuse addr/port"

This reverts commit c191a836a908d1dd6b40c503741f91b914de3348.

It causes known regressions for programs that expect to be able to use
SO_REUSEADDR to shutdown a socket, then successfully rebind another
socket to the same ID.

Programs such as haproxy and amavisd expect this to work.

This should fix kernel bugzilla 32832.



