From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH v2] Gemini: Gigabit ethernet driver
Date: Wed, 29 Dec 2010 21:42:37 +0000
Message-ID: <1293658957.3028.14.camel@localhost>
References: <1202721929.17594.1293513142947.JavaMail.root@tahiti.vyatta.com>
	 <alpine.LNX.2.00.1012291750060.9177@localhost>
	 <1293647441.2413.2.camel@edumazet-laptop> <20101229112827.203469c2@nehalam>
	 <1293652346.7150.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Hans Ulli Kroll <ulli.kroll@googlemail.com>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	gemini-board-dev@lists.berlios.de, netdev@vger.kernel.org,
	Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:1979 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753156Ab0L2Vmp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Dec 2010 16:42:45 -0500
In-Reply-To: <1293652346.7150.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-12-29 at 20:52 +0100, Eric Dumazet wrote:
> Le mercredi 29 d=C3=A9cembre 2010 =C3=A0 11:28 -0800, Stephen Hemming=
er a =C3=A9crit :
>=20
> > It looks like the comment/documentation in netdevice.h is incorrect=
=2E
> >=20
> >  * struct net_device_stats* (*ndo_get_stats)(struct net_device *dev=
);
> >  *	Called when a user wants to get the network device usage
> >  *	statistics. Drivers must do one of the following:
> >  *	1. Define @ndo_get_stats64 to fill in a zero-initialised
> >  *	   rtnl_link_stats64 structure passed by the caller.
> >  *	2. Define @ndo_get_stats to update a net_device_stats structure
> >  *	   (which should normally be dev->stats) and return a pointer to
> >  *	   it. The structure may be changed asynchronously only if each
> >  *	   field is written atomically.
> >  *	3. Update dev->stats asynchronously and atomically, and define
> >  *	   neither operation.
> >=20
>=20
> You mean we should insert a new line ?
> I believe this documentation is up to date.
[...]

It would also be worth explicitly stating that there is no serialisatio=
n
of calls to these operations, so drivers may need to use a spinlock in
their implementation.  I wrote this description under the mistaken
belief that there was some serialisation, and point 2 reflects that.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

