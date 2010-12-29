From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v2] Gemini: Gigabit ethernet driver
Date: Wed, 29 Dec 2010 19:30:41 +0100
Message-ID: <1293647441.2413.2.camel@edumazet-laptop>
References: <1202721929.17594.1293513142947.JavaMail.root@tahiti.vyatta.com>
	 <alpine.LNX.2.00.1012291750060.9177@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	gemini-board-dev@lists.berlios.de, netdev@vger.kernel.org,
	Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>
To: Hans Ulli Kroll <ulli.kroll@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49954 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752717Ab0L2Sas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Dec 2010 13:30:48 -0500
Received: by wyb28 with SMTP id 28so10349062wyb.19
        for <netdev@vger.kernel.org>; Wed, 29 Dec 2010 10:30:46 -0800 (PST)
In-Reply-To: <alpine.LNX.2.00.1012291750060.9177@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 29 d=C3=A9cembre 2010 =C3=A0 17:56 +0100, Hans Ulli Kroll a=
 =C3=A9crit :
>=20
> On Mon, 27 Dec 2010, Stephen Hemminger wrote:
>=20
> >=20
> >=20
> > ----- Original Message -----
> > > On Mon, 2010-12-27 at 20:21 +0100, Hans Ulli Kroll wrote:
> > > [...]
> > > > BTW:
> > > >
> > > > Why u64_stats ?
> > > > I see only a few driver are using u64_stats.
> > > > vlan, br_device and some intel driver
> > > > no gigabit driver for marvell devices uses u64_stats
> > >=20
> > > All new net drivers should implement 64-bit stats. net_device_sta=
ts is
> > > kept for backward compatibility because we couldn't change all th=
e
> > > existing drivers at once (it's not a simple change for all of the=
m).
> > >=20
> > > Ben.
> >=20
> > BS. drivers with old stats are fine. 64 bit only really matters
> > at higher speed. Anyway, it is the kind of thing that can easily
> > be fixed later after driver is merged.
> >=20
> >=20
>=20
> I've readed the Intel driver.
>=20
> So we must also implement to old net_stats interface, for backward=20
> compatibility ?

If you implement new (64bit) stats, old one is not used at all.

Check net/core/dev.c : dev_get_stats()

If ndo_get_stats64() method is implemented, its called, and legacy
interfaces are ignored.



