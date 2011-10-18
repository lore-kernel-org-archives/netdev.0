From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#645589: linux-image-3.0.0-2-amd64: sky2 rx errors on 3.0,
 2.6.32 works
Date: Tue, 18 Oct 2011 04:27:55 +0100
Message-ID: <1318908480.3340.79.camel@deadeye>
References: <20111017074016.6840.77265.reportbug@thor.viidakko.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-wR2qgptWQdPzXV6WIdWP"
Cc: 645589@bugs.debian.org, Antti Salmela <asalmela@iki.fi>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50951 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752460Ab1JRD2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 23:28:19 -0400
In-Reply-To: <20111017074016.6840.77265.reportbug@thor.viidakko.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wR2qgptWQdPzXV6WIdWP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-10-17 at 10:40 +0300, Antti Salmela wrote:
> Package: linux-2.6
> Version: 3.0.0-5
> Severity: normal
>=20
>=20
> sky2 loses packets on 3.0 (-3 and -5) and 3.1-rc7, 2.6.32-38 and
> setting interface to promiscuous works.
>=20
> [   60.118244] sky2 0000:02:00.0: eth0: rx error, status 0xb92100 length =
185
> [   62.664370] sky2 0000:02:00.0: eth0: rx error, status 0x602100 length =
96
> [   63.370051] sky2 0000:02:00.0: eth0: rx error, status 0x422100 length =
66
> [   63.714672] sky2 0000:02:00.0: eth0: rx error, status 0x722100 length =
114
> [   64.513458] device eth0 entered promiscuous mode

It looks like this is a bug in accounting of VLAN tags, though I don't
see what difference promiscuous mode should make.

The log messages show that status has the VLAN flag (bit 13) set and the
length field (bits 16:28) equals the length passed into sky2_receive(),
but that function expects the length field to be greater by VLAN_HLEN.

This device is:

[...]
> 02:00.0 Ethernet controller [0200]: Marvell Technology Group Ltd. 88E8053=
 PCI-E Gigabit Ethernet Controller [11ab:4362] (rev 19)
> 	Subsystem: ASUSTeK Computer Inc. Marvell 88E8053 Gigabit Ethernet contro=
ller PCIe (Asus) [1043:8142]
> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step=
ping- SERR- FastB2B- DisINTx+
> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 0, Cache Line Size: 16 bytes
> 	Interrupt: pin A routed to IRQ 43
> 	Region 0: Memory at cdefc000 (64-bit, non-prefetchable) [size=3D16K]
> 	Region 2: I/O ports at c800 [size=3D256]
> 	Expansion ROM at cdec0000 [disabled] [size=3D128K]
> 	Capabilities: <access denied>
> 	Kernel driver in use: sky2
[...]

Ben.

--=20
Ben Hutchings
No political challenge can be met by shopping. - George Monbiot

--=-wR2qgptWQdPzXV6WIdWP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATpzyO+e/yOyVhhEJAQoF6g/9FE1bDjowY696oNF3GheUAwR6xhUlWeJ1
pXiOvITIroIysRRqL1TVW1o+ho/h8OrLm9MrvqttXffSQtJUASo66pIVIDSuJyz/
1LHLENlEchdu6kDnLX/D/ucRHL/SwtrSgeWlp5+sj9ZHXjG55Vzt/FZOF1NugoXt
poLZBmujIDAsHn9zUJw3+Si+XpsobWZj01ScNkHXhylZ6iOYkWqCsqP5qe6YHzVv
6byTpoCCOKcYfssBXxbrUy5TO6vtJq6zyXooVZzg+mXqJ6pjcE8i03TbZzi1U8Qy
m4J14npvMLaG9tsoLApD8PuMKjFJz9qDNjrOlVTcmdH2HjLKGRoF2FHwuVFfu4TS
2+V2OP0630Ss8hb2osIzPt3mkkooxUiwPLx98UF1Olb4W0uWb4DZRjpQYxT/DVJ2
bejyevo0dnPL4LuhyimUoGj5SNMzPSwLbI9CWgNH5WeHeKdlJRZRzrqMdJ4dqQ+x
9DdjwDooY5OOHNvmd1o3aYcJed8N4sslP282GO8NF77lTtbqmAEIeNRooT/wMpWk
iyU3kVXaKDR6uC4bNoMvadfcjPKVAO7Qrdw2wlvATtNn3Y1QZdOQDHEEwMuk47Pp
QhWSEPGRHMypLv4z9yDX7DkjwxO5p+sz33D0L+szvlzSjulYeOrTvE/vUB0RxkcR
au0wEMe5eF8=
=0sfZ
-----END PGP SIGNATURE-----

--=-wR2qgptWQdPzXV6WIdWP--
