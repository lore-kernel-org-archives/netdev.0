From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH v2] Gemini: Gigabit ethernet driver
Date: Wed, 29 Dec 2010 11:57:16 -0800
Message-ID: <20101229115716.1eecec27@nehalam>
References: <1202721929.17594.1293513142947.JavaMail.root@tahiti.vyatta.com>
	<alpine.LNX.2.00.1012291750060.9177@localhost>
	<1293647441.2413.2.camel@edumazet-laptop>
	<20101229112827.203469c2@nehalam>
	<1293652346.7150.10.camel@edumazet-laptop>
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
Received: from mail.vyatta.com ([76.74.103.46]:45283 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752423Ab0L2T5T convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Dec 2010 14:57:19 -0500
In-Reply-To: <1293652346.7150.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 Dec 2010 20:52:26 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mercredi 29 d=E9cembre 2010 =E0 11:28 -0800, Stephen Hemminger a =E9=
crit :
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
>=20
>=20
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index cc916c5..3add243 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -721,7 +721,9 @@ struct xps_dev_maps {
>   *                      struct rtnl_link_stats64 *storage);
>   * struct net_device_stats* (*ndo_get_stats)(struct net_device *dev)=
;
>   *	Called when a user wants to get the network device usage
> - *	statistics. Drivers must do one of the following:
> + *	statistics.
> + *
> + * Drivers must do one of the following:
                     ^
                    only

Need to make it clear that get_stats is not needed if get_stats64 is de=
fined.
                     =20

--=20
