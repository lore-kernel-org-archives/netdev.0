From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: e100 + VLANs?
Date: Tue, 11 Oct 2011 16:38:55 -0700
Message-ID: <20111011163855.0000646f@unknown>
References: <20111010101954.GB2840382@jupiter.n2.diac24.net>
	<4E9307CB.4050704@msgid.tls.msk.ru>
	<1318259152.3227.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111010151343.GB3260852@jupiter.n2.diac24.net>
	<4E932278.8010802@tls.msk.ru>
	<4E941198.9000307@msgid.tls.msk.ru>
	<CAL4WiiphpyizVaNkvOdJp1+UK53TkGw9RXnC-vzH7fTNpBAAEA@mail.gmail.com>
	<4E942F8A.90205@msgid.tls.msk.ru>
	<1318334674.2538.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<4E943CF7.6030905@msgid.tls.msk.ru>
	<20111011152917.GE2840382@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA256;
 boundary="Sig_/GBzDnEN8Qlvpmsnjnv4DAvI"; protocol="application/pgp-signature"
Cc: Michael Tokarev <mjt@tls.msk.ru>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34341 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751758Ab1JKXjA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 19:39:00 -0400
In-Reply-To: <20111011152917.GE2840382@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/GBzDnEN8Qlvpmsnjnv4DAvI
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 11 Oct 2011 08:29:18 -0700
David Lamparter <equinox@diac24.net> wrote:

> On Tue, Oct 11, 2011 at 04:56:23PM +0400, Michael Tokarev wrote:
> > So it looks like the card merely ignores these packets.
> >=20
> > So little result for so much efforts... :(
> >=20
> > But it is not really that bad I think - it is an obsolete hardware.
>=20
> The knowledge and code for this is actually around line 1142 of e100.c:
>         if (nic->mac >=3D mac_82558_D101_A4) {
>                 config->fc_disable =3D 0x1;       /* 1=3DTx fc off, 0=3DT=
x fc on */
>                 config->mwi_enable =3D 0x1;       /* 1=3Denable, 0=3Ddisa=
ble */
>                 config->standard_tcb =3D 0x0;     /* 1=3Dstandard, 0=3Dex=
tended */
>                 config->rx_long_ok =3D 0x1;       /* 1=3DVLANs ok, 0=3Dst=
andard */
>=20
> where rx_long_ok is the configuration bit to enable frame reception
> for >1514 byte frames. I guess your card is < mac_82558_D101_A4...
>=20
> (cf. "Intel 8255x 10/100 Mbps Ethernet Controller Family Open Source
> Software Developer Manual" page 78/86 - "Long Receive OK. This bit is
> reserved on the 82557 and should be set to 0. When this bit is set on
> the 82558 or 82559, the device considers received frames that have
> a data field longer than 1500 bytes as good frames.")

David, thank you for posting that, while you were typing I was
researching the same thing, so FWIW, I concur with your conclusion.

ouch, OP your hardware is really really old:
> 00:12.0 Ethernet controller: Intel Corporation 82557/8/9/0/1 Ethernet Pro=
 100 (rev 02)
> Subsystem: Intel Corporation EtherExpress PRO/100B (TX)

rev 2 is D100_C, which is 82557.

the hardware is NOT capable of long receives (i.e. vlan packets).
If it was then they should generally fit in the receive buffer and be
handled and not discarded.

--Sig_/GBzDnEN8Qlvpmsnjnv4DAvI
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (MingW32)

iQIcBAEBCAAGBQJOlNOSAAoJEFi+OMPmMDUeuXkQAL/SRjv26D1yjKLoLUW7/22x
+jLoW4dDXNiXjf/mQxJgmOVxDkv2hW5P5uTuE3ADy6TLeFMbMaDfzKPGMjDZmrbz
tQlTrIKtZunP5Z+gY1mHzZVLsf/cI7NOWFqm8PTuB/nV+0l+7hTe5t59Ag8+4vyO
oM9u1PozTQkHZyYrFKzZpJDcReDb0Vrx1s+cWChuekAT2lb2oz5YSwXflfZ4sMJW
LvB4wxAh6vFOZsUChhWdj480Bq7WtN/vBL53bf16n2KCYfn4nXnL9YpMOl70oan0
oz00kmCJGBccvwouV0/JsNQIiOhGN+3NMpYskURrnlSPyUppTDgi+RW4Y5shcSDN
il/SgHtD24dzkHwTtW1U3Q6o4NovVpJXYZcx7l/sFUunlzIz20p/2aJYAnJD2jIx
lSvMgfVIZ9aTR/iWrUKpBDK1MhjSH//Hq/iQpZEELDW7qlbW27G3pIuc9UApukks
OcoSMwTs7VzvdH8peb7mNCAFAIZdIN4512JhmPAqzibR5Kw5cTWMRRGVneqJnyLQ
Bc8zUMmWjipLg+jPjLHrY2h7ChVnUfLAwoOMS1xKr85Yd/Jt5l6pyH5L1nw5Tm99
rPJkhB/XzGWn/13STLd3W89J4dGLnT3WLgO+ZnWs04iEm4+hJ2h8+ErhtCzloVwL
RuOOu47H+RnLa5QCoQ/u
=5uo+
-----END PGP SIGNATURE-----

--Sig_/GBzDnEN8Qlvpmsnjnv4DAvI--
