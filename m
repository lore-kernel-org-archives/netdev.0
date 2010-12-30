From: David Miller <davem@davemloft.net>
Subject: Re: sysctls below net.ipv[46].conf.all not working as expected
Date: Thu, 30 Dec 2010 12:30:23 -0800 (PST)
Message-ID: <20101230.123023.226775556.davem@davemloft.net>
References: <20101229160607.GH14221@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58179
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754941Ab0L3U3w convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Dec 2010 15:29:52 -0500
In-Reply-To: <20101229160607.GH14221@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Wed, 29 Dec 2010 17:06:07 +0100

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

The "all" value is propagated at the first moment that the ipv6 device
private is created, usually that is when the device is first brought up
which means it can happen as early as the exact moment the device is
registered.

Therefore, if you want "all" to apply to "eth0", you must make sure
the sysctl is set properly before the device is registered.
