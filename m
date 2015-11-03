From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Tue, 3 Nov 2015 16:15:00 +0100
Message-ID: <5638CF74.7030001@pengutronix.de>
References: <1446419775-5215-1-git-send-email-marex@denx.de>
 <201511021916.18117.marex@denx.de>
 <666821254.20151102231521@cogentembedded.com>
 <201511022125.47892.marex@denx.de>
 <CAAP7uc+3sJRJ9khC6x58ULy2vR8fTCi6gMwtgV_0GAWW49AwLg@mail.gmail.com>
 <56389C38.4080508@pengutronix.de>
 <CAAP7ucLhzqh8+QxYJwx-8-DqSb6YqV0ZXXVGqY=OUUnzAu5EVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="sfsVBvwTGlfdu05iEFwsQW2QbaDrNsmtG"
Cc: Marek Vasut <marex@denx.de>,
	Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Aleksander Morgado <aleksander@aleksander.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:42816 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098AbbKCPPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 10:15:14 -0500
In-Reply-To: <CAAP7ucLhzqh8+QxYJwx-8-DqSb6YqV0ZXXVGqY=OUUnzAu5EVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--sfsVBvwTGlfdu05iEFwsQW2QbaDrNsmtG
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 11/03/2015 04:06 PM, Aleksander Morgado wrote:
>> What about maintainability? Why take care of two almost identical
>> subsystems? With making one stack "simpler" you increase, from my poin=
t
>> of view, the costs of maintaining even more. If you fix problems in on=
e
>> stack you have to adopt the other, too.
>=20
> If they can share common code, that's fine, that probably can be
> worked around if needed. My main issues are actually with all the
> behavior that CAN supports and doesn't make much sense in ARINC, like
> the complex ID filtering scheme for example (ARINC just requires 256
> bits for a minimum filter),

I think it should be possible to use a simple/different filter mechanism
for ARINC packages.

> or the duplex TX/RX setup for channels
> (channels are either RX or TX, not both), or the local
> echoing/loopback (which wouldn't make much sense for TX-only
> channels).

Local echo/loopback comes in two flavours:
- Other socket receive local generate frames, too.
  This is interesting if you want to merge two ARINC node on single
  device.
- Sending socket receives send frame, too. This is useful if you need
  the feedback that the frame has _really_ been send, not just pushed
  into the networking stack.

> The minimum subset of features required by an ARINC driver
> is actually very small. Trying to "fit" ARINC as a subset of CAN may
> actually be harder than keeping it separate maintainability wise.
> Maybe the issue here is that the original patch is too CAN-like while
> it shouldn't be, don't know.

regards,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--sfsVBvwTGlfdu05iEFwsQW2QbaDrNsmtG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWOM90AAoJEP5prqPJtc/HoFMH/Rn7XEptt9T4VhWumh6FBAd5
2K3KzyCUF/O8W767gdQouWbOcHFMsAITEmCH2vidafDw4G1eDwnYb3FNP8ovrqzN
XngVoA3wuwk2tAk+juFTVVekUK3Q6wB0F+uLomMfuLetDsuGDGoOXFF+a0WAEDbV
MbqHeecLo//5wBYl7yHxg9flaoL7e0LgfnjzCiuFx2BtcvDvzd6WRpG34lJea+qe
/bdHH9M2qLxFU23H9QjVerUYkzoKtaCWnVYPCeKj330LxgteCUMk9dJC1NyD8Eqo
OgyKsSajMthTDTcxVJFi3RyNTOk6RQ4bLSbm9I4/eb1Gxm7VyUL/TrUbLmB9CSg=
=jUht
-----END PGP SIGNATURE-----

--sfsVBvwTGlfdu05iEFwsQW2QbaDrNsmtG--
