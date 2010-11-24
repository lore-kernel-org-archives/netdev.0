From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] af_unix: unix_write_space() use keyed wakeups
Date: Wed, 24 Nov 2010 01:28:11 +0100
Message-ID: <1290558491.2866.125.camel@edumazet-laptop>
References: <20101029191857.5f789d56@chocolatine.cbg.collabora.co.uk>
	 <1288380431.2680.3.camel@edumazet-laptop>
	 <1288421084.2680.717.camel@edumazet-laptop>
	 <20101030223609.2faa4eae@chocolatine.cbg.collabora.co.uk>
	 <1290554876.2158.5.camel@Nokia-N900-51-1>
	 <20101124002032.572b7292@chocolatine.cbg.collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pauli Nieminen <pauli.nieminen@collabora.co.uk>,
	Davide Libenzi <davidel@xmailserver.org>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Rainer Weikusat <rweikusat@mssgmbh.com>
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57922 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755479Ab0KXA2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 19:28:19 -0500
In-Reply-To: <20101124002032.572b7292@chocolatine.cbg.collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 24 novembre 2010 =C3=A0 00:20 +0000, Alban Crequy a =C3=A9c=
rit :
> Le Wed, 24 Nov 2010 01:27:56 +0200,
> Pauli Nieminen <pauli.nieminen@collabora.co.uk> a =C3=A9crit :
>=20
> > ----- Original message -----
> > > Le Sat, 30 Oct 2010 08:44:44 +0200,
> > > Eric Dumazet <eric.dumazet@gmail.com> a =C3=A9crit :
> > >=20
> > > > We still loop on 800 items, on each
> > > > wake_up_interruptible_sync_poll() call, so maybe we want to
> > > > optimize this later, adding a global key, ORing all items keys.=
 I
> > > > dont think its worth the added complexity, given the biased usa=
ge
> > > > of your program (800 'listeners' to one event). Is it a real li=
fe
> > > > scenario ?
> > >=20
> > > Pauli Nieminen told me about his performance problem in select() =
so
> > > I wrote the test program but I don't know what exactly is the rea=
l
> > > life scenario.
> > >=20
> >=20
> > Real world scenario is xsever that has tens client connections to
> > manage. When xserver is happily sleeping at seclect call some clien=
t
> > reading events/replies from server triggers in kernel looping over
> > all xserver fds. xserver isn't waiting for socket to became writeab=
le
> > in ussual cases so kernel schedules back to client.
>=20
> But are they SOCK_STREAM or SOCK_DGRAM sockets? The patches fix
> performances with SOCK_DGRAM. If the xserver scenario is with
> SOCK_STREAM sockets, your problem is probably still unfixed.
>=20


It should not matter ?

commit 67426b756c4d52c51 (af_unix: use keyed wakeups ) makes
unix_write_space() call wake_up_interruptible_sync_poll() instead of
wake_up_interruptible_sync().

So it should be fixed for both STREAM/DGRAM sockets ?



