From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next] vlan: Pass ethtool get_ts_info queries to real
 device.
Date: Sun, 23 Nov 2014 19:04:57 +0000
Message-ID: <1416769497.7215.56.camel@decadent.org.uk>
References: <1416575780-19132-1-git-send-email-richardcochran@gmail.com>
	 <1416712512.7215.34.camel@decadent.org.uk> <20141123160533.GA4562@netboy>
	 <20141123.134809.1311687203339230014.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-zHhYjCH4ovxrVFodH5vA"
Cc: richardcochran@gmail.com, netdev@vger.kernel.org,
	stefan.sorensen@spectralink.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:48998 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752014AbaKWTFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2014 14:05:11 -0500
In-Reply-To: <20141123.134809.1311687203339230014.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-zHhYjCH4ovxrVFodH5vA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-11-23 at 13:48 -0500, David Miller wrote:
> From: Richard Cochran <richardcochran@gmail.com>
> Date: Sun, 23 Nov 2014 17:05:35 +0100
>=20
> > On Sun, Nov 23, 2014 at 03:15:12AM +0000, Ben Hutchings wrote:
> >> This assumes that the same PTP capabilities apply to VLAN-tagged frame=
s.
> >> I don't think it's at all safe to assume that RX filter modes other th=
an
> >> HWTSTAMP_FILTER_ALL will include VLAN-tagged frames.  I think it is
> >> necessary to define additional modes that explicitly include VLAN-tagg=
ed
> >> frames.
> >=20
> > Unsafe? How?
> >=20
> > Do you mean that some HW cannot identify and time stamp PTP frames
> > when VLAN tagged? That is surely disappointing for people who shell
> > out money for such cards, but it is hardly unsafe.
>=20
> Ben, you will have to provide a concrete example of a chip that will
> do the wrong thing with Richard's change.
>=20
> Hypotheticals won't cut it.

The two datasheets I've looked at so far (EG20T for pch_gbe driver,
BF518 for bfin_mac driver) mention support for 802.1q but not 802.1ad.
I already mentioned ptp_classify.c doesn't support 802.1ad, and I can't
see how it would ever make sense to run PTP directly over 802.1ad
anyway.

I'll read some more datasheets to see whether 802.1q is generally
supported, but for 802.1ad VLAN devices I think we should pass-through
only the NONE and ALL filter capabilities.

Ben.

--=20
Ben Hutchings
Never put off till tomorrow what you can avoid all together.

--=-zHhYjCH4ovxrVFodH5vA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVHIv3ee/yOyVhhEJAQrIRA//RCpF54rqGIHYgNJhxSzdg6IUw2i73TZ6
fY/SadCEF7w2rnFd2Vawkclny7taxsP35TugK2x16ot85iNDHygQEqZ+2VVPHHTo
1/yvQ1SHsxYtPP7IYWg0r8rUY+5CvQFntNy4BxhMpJO3InsdTzsvgcxeTB9IsMGR
0yujBx0k/CL71IhZUUFjy7yWwx/WE1BjUQ8zYCwFsODXHKd/BpQ6d5l/eQSxmWOt
6VSpFUY12FP3yqgO9skKAGyZbmzMWNsPkRNS/DQ/UyornPXdiN9N+V5iSs2nEBOo
bmAAxqXI0xYNSSJpwYZew5CQ1zPb9ezJ/dV1C/dlOJdRUuMN8CR822aOjch9+H2D
/x2hJRCRsEfmxpzAxhFcc1QZC+79uDAl9+vmkihgZVu3pXLNywt7WR+rHnvbcfiQ
57jy64umQ8Su/X6H32UGW7R95oWHkJyaWNBvN6NEv7JByo/J3fh7YnOxn+OCRFA1
28t1sRNYJV/dtpcKCDWG7xsJaFAugmN6Z2h3lDEO/boRyzopu/VVL5wvZCR4GG5g
kuEi3nCUFDW0TBqBnOI+Hyw0pIu5Qza1AUACum9IcKX0v3DLWqd6gBsZdoaSXiEY
I1dfmBa03SNf4sANhnw5H9QCiwT2PEptKLpmlS2CsRg8w79IFXbKjYZnws2KPVrP
t3WrM0pozv4=
=6Isv
-----END PGP SIGNATURE-----

--=-zHhYjCH4ovxrVFodH5vA--
