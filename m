From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: sysctls below net.ipv[46].conf.all not working as expected
Date: Thu, 30 Dec 2010 21:43:19 +0100
Message-ID: <20101230204319.GE14221@pengutronix.de>
References: <20101229160607.GH14221@pengutronix.de> <20101230.123023.226775556.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:38660 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755249Ab0L3UnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Dec 2010 15:43:20 -0500
Content-Disposition: inline
In-Reply-To: <20101230.123023.226775556.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

On Thu, Dec 30, 2010 at 12:30:23PM -0800, David Miller wrote:
> From: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> Date: Wed, 29 Dec 2010 17:06:07 +0100
>=20
> > I did the following:
> >=20
> > 	cassiopeia:~# sysctl net.ipv6.conf.all.use_tempaddr
> > 	net.ipv6.conf.all.use_tempaddr =3D 0
> >=20
> > 	cassiopeia:~# sysctl net.ipv6.conf.eth0.use_tempaddr
> > 	net.ipv6.conf.eth0.use_tempaddr =3D 0
> >=20
> > 	cassiopeia:~# sysctl -w net.ipv6.conf.all.use_tempaddr=3D1
> > 	net.ipv6.conf.all.use_tempaddr =3D 1
> >=20
> > 	cassiopeia:~# sysctl net.ipv6.conf.all.use_tempaddr
> > 	net.ipv6.conf.all.use_tempaddr =3D 1
> >=20
> > 	cassiopeia:~# sysctl net.ipv6.conf.eth0.use_tempaddr
> > 	net.ipv6.conf.eth0.use_tempaddr =3D 0
> >=20
> > Here I would have expected that eth0's use_tempaddr is 1, too.  The
> > problem is not that this entry isn't writeable:
>=20
> The "all" value is propagated at the first moment that the ipv6 devic=
e
> private is created, usually that is when the device is first brought =
up
> which means it can happen as early as the exact moment the device is
> registered.
>=20
> Therefore, if you want "all" to apply to "eth0", you must make sure
> the sysctl is set properly before the device is registered.
I thought this is what "default" was used for?!
If you are really right, the documentation is (IMHO) misleading.  e.g.
Documentation/networking/ip-sysctl.txt tells:

	conf/default/*:
		Change the interface-specific default settings.

	conf/all/*:
		Change all the interface-specific settings.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
