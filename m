From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: Re: [PATCH] af_unix: unix_write_space() use keyed wakeups
Date: Wed, 24 Nov 2010 00:20:32 +0000
Message-ID: <20101124002032.572b7292@chocolatine.cbg.collabora.co.uk>
References: <20101029191857.5f789d56@chocolatine.cbg.collabora.co.uk>
	<1288380431.2680.3.camel@edumazet-laptop>
	<1288421084.2680.717.camel@edumazet-laptop>
	<20101030223609.2faa4eae@chocolatine.cbg.collabora.co.uk>
	<1290554876.2158.5.camel@Nokia-N900-51-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Davide Libenzi <davidel@xmailserver.org>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Rainer Weikusat <rweikusat@mssgmbh.com>
To: Pauli Nieminen <pauli.nieminen@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.128.226]:39641 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754281Ab0KXAWa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 19:22:30 -0500
In-Reply-To: <1290554876.2158.5.camel@Nokia-N900-51-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Wed, 24 Nov 2010 01:27:56 +0200,
Pauli Nieminen <pauli.nieminen@collabora.co.uk> a =C3=A9crit :

> ----- Original message -----
> > Le Sat, 30 Oct 2010 08:44:44 +0200,
> > Eric Dumazet <eric.dumazet@gmail.com> a =C3=A9crit :
> >=20
> > > We still loop on 800 items, on each
> > > wake_up_interruptible_sync_poll() call, so maybe we want to
> > > optimize this later, adding a global key, ORing all items keys. I
> > > dont think its worth the added complexity, given the biased usage
> > > of your program (800 'listeners' to one event). Is it a real life
> > > scenario ?
> >=20
> > Pauli Nieminen told me about his performance problem in select() so
> > I wrote the test program but I don't know what exactly is the real
> > life scenario.
> >=20
>=20
> Real world scenario is xsever that has tens client connections to
> manage. When xserver is happily sleeping at seclect call some client
> reading events/replies from server triggers in kernel looping over
> all xserver fds. xserver isn't waiting for socket to became writeable
> in ussual cases so kernel schedules back to client.

But are they SOCK_STREAM or SOCK_DGRAM sockets? The patches fix
performances with SOCK_DGRAM. If the xserver scenario is with
SOCK_STREAM sockets, your problem is probably still unfixed.

