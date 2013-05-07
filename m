From: Lukas Tribus <luky-37@hotmail.com>
Subject: RE: source IP address for ARP requests
Date: Tue, 7 May 2013 20:15:36 +0200
Message-ID: <DUB107-W47D427AB8714864D88CD46EDBA0@phx.gbl>
References: <51891E0D.7050907@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Michael Tokarev <mjt@tls.msk.ru>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub0-omc4-s24.dub0.hotmail.com ([157.55.2.99]:32288 "EHLO
	dub0-omc4-s24.dub0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753396Ab3EGSVt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 May 2013 14:21:49 -0400
In-Reply-To: <51891E0D.7050907@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>=A0 eth0=A0 10.0.0.1/32
>=A0 eth1=A0 192.168.1.1/24
>=A0 route add 10.0.0.2 dev eth1 src 10.0.0.1
>=20
> namely, so that just one ip address is available
> on an "unrelated" subnet, with "our" address taken
> from another interface.
>=20
> With this config, ARPs for 10.0.0.2 are sent to eth1
> with source address of 192.168.1.1, even if "src"
> is configured for the route in question:
>=20
>=A0 9:28:46.220680 ARP, Request who-has 10.0.0.2 tell
>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 192.16=
8.1.1, length 28
>=20
> Is that right, or should the host send ARP requests
> with src=3D10.0.0.1?

I suspect you cannot change the behavior of layer 2 discovery
protocols by configuring a certain layer 3 parameter (a route +
"src").

Also from an ARP perspective, this is imho correct behavior, because
10.0.0.2 should learn "sender hardware address" and "sender protocol
address" from the ARP _request_ and add them to its own ARP table -
without an additional ARP request. 10.0.0.2 is connected to eth1, so
only mac and ip address of eth1 counts in this case (=3D 192.168.1.1).



Regards,
Lukas 		 	   		  