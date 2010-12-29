From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH v2] Gemini: Gigabit ethernet driver
Date: Wed, 29 Dec 2010 11:28:27 -0800
Message-ID: <20101229112827.203469c2@nehalam>
References: <1202721929.17594.1293513142947.JavaMail.root@tahiti.vyatta.com>
	<alpine.LNX.2.00.1012291750060.9177@localhost>
	<1293647441.2413.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hans Ulli Kroll <ulli.kroll@googlemail.com>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	gemini-board-dev@lists.berlios.de, netdev@vger.kernel.org,
	Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39174 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752879Ab0L2T2b convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Dec 2010 14:28:31 -0500
In-Reply-To: <1293647441.2413.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 Dec 2010 19:30:41 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mercredi 29 d=E9cembre 2010 =E0 17:56 +0100, Hans Ulli Kroll a =E9=
crit :
> >=20
> > On Mon, 27 Dec 2010, Stephen Hemminger wrote:
> >=20
> > >=20
> > >=20
> > > ----- Original Message -----
> > > > On Mon, 2010-12-27 at 20:21 +0100, Hans Ulli Kroll wrote:
> > > > [...]
> > > > > BTW:
> > > > >
> > > > > Why u64_stats ?
> > > > > I see only a few driver are using u64_stats.
> > > > > vlan, br_device and some intel driver
> > > > > no gigabit driver for marvell devices uses u64_stats
> > > >=20
> > > > All new net drivers should implement 64-bit stats. net_device_s=
tats is
> > > > kept for backward compatibility because we couldn't change all =
the
> > > > existing drivers at once (it's not a simple change for all of t=
hem).
> > > >=20
> > > > Ben.
> > >=20
> > > BS. drivers with old stats are fine. 64 bit only really matters
> > > at higher speed. Anyway, it is the kind of thing that can easily
> > > be fixed later after driver is merged.
> > >=20
> > >=20
> >=20
> > I've readed the Intel driver.
> >=20
> > So we must also implement to old net_stats interface, for backward=20
> > compatibility ?
>=20
> If you implement new (64bit) stats, old one is not used at all.
>=20
> Check net/core/dev.c : dev_get_stats()
>=20
> If ndo_get_stats64() method is implemented, its called, and legacy
> interfaces are ignored.

It looks like the comment/documentation in netdevice.h is incorrect.

 * struct net_device_stats* (*ndo_get_stats)(struct net_device *dev);
 *	Called when a user wants to get the network device usage
 *	statistics. Drivers must do one of the following:
 *	1. Define @ndo_get_stats64 to fill in a zero-initialised
 *	   rtnl_link_stats64 structure passed by the caller.
 *	2. Define @ndo_get_stats to update a net_device_stats structure
 *	   (which should normally be dev->stats) and return a pointer to
 *	   it. The structure may be changed asynchronously only if each
 *	   field is written atomically.
 *	3. Update dev->stats asynchronously and atomically, and define
 *	   neither operation.

--=20
