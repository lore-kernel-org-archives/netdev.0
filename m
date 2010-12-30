From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: sysctls below net.ipv[46].conf.all not working as expected
Date: Thu, 30 Dec 2010 21:20:36 +0100
Message-ID: <20101230202036.GD14221@pengutronix.de>
References: <20101229160607.GH14221@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marco d'Itri <md@linux.it>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:58415 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755043Ab0L3UUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Dec 2010 15:20:39 -0500
Content-Disposition: inline
In-Reply-To: <20101229160607.GH14221@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello again,

On Wed, Dec 29, 2010 at 05:06:07PM +0100, Uwe Kleine-K=F6nig wrote:
> I did the following:
>=20
> 	cassiopeia:~# sysctl net.ipv6.conf.all.use_tempaddr
> 	net.ipv6.conf.all.use_tempaddr =3D 0
>=20
> 	cassiopeia:~# sysctl net.ipv6.conf.eth0.use_tempaddr
> 	net.ipv6.conf.eth0.use_tempaddr =3D 0
>=20
> 	cassiopeia:~# sysctl -w net.ipv6.conf.all.use_tempaddr=3D1
> 	net.ipv6.conf.all.use_tempaddr =3D 1
>=20
> 	cassiopeia:~# sysctl net.ipv6.conf.all.use_tempaddr
> 	net.ipv6.conf.all.use_tempaddr =3D 1
>=20
> 	cassiopeia:~# sysctl net.ipv6.conf.eth0.use_tempaddr
> 	net.ipv6.conf.eth0.use_tempaddr =3D 0
>=20
> Here I would have expected that eth0's use_tempaddr is 1, too.  The
> problem is not that this entry isn't writeable:
>=20
> 	cassiopeia:~# sysctl -w net.ipv6.conf.eth0.use_tempaddr=3D1
> 	net.ipv6.conf.eth0.use_tempaddr =3D 1
>=20
> 	cassiopeia:~# sysctl net.ipv6.conf.eth0.use_tempaddr
> 	net.ipv6.conf.eth0.use_tempaddr =3D 1
>=20
> I got the same results when using net.ipv4.conf.all.rp_filter (and
> net.ipv4.conf.eth0.rp_filter resp.)
>=20
> Is this a bug or just my failure to see how conf/all works?
I put the following in my /etc/sysctl.conf:

	net.ipv6.conf.default.use_tempaddr =3D 1
	net.ipv6.conf.all.use_tempaddr =3D 1
	net.ipv6.conf.eth0.use_tempaddr =3D 1

and after a reboot eth0 got a temporary dynamic address, eth1 did not.
So it doesn't seem to be as guessed by someone on #debian-kernel that
the setting works but isn't propagated back to the sysctl of the
interface.

This makes me wonder how useful the lines

	net.ipv4.conf.default.rp_filter =3D 1
	net.ipv4.conf.all.rp_filter =3D 1

(suggested by the Debian package netbase) are.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
