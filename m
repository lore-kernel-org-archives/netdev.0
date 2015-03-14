From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4 1/3] can: kvaser_usb: Fix tx queue start/stop
 race conditions
Date: Sat, 14 Mar 2015 15:58:39 +0100
Message-ID: <55044C9F.2070105@pengutronix.de>
References: <20150226152011.GA6075@linux> <20150314130249.GA20796@linux> <55043A7E.7040001@pengutronix.de> <20150314143820.GA22071@linux>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="2qmhUb177Bre9NvSD1WK2jO8hxR42OUJE"
Cc: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andri Yngvason <andri.yngvason@marel.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: "Ahmed S. Darwish" <darwish.07@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20150314143820.GA22071@linux>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--2qmhUb177Bre9NvSD1WK2jO8hxR42OUJE
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/14/2015 03:38 PM, Ahmed S. Darwish wrote:
>> Applied to can. This will go into David's net tree and finally into
>> net-next. Then I'll apply patches 2+3. Nag me, if I forget about them =
;)
>>
>=20
> Thanks! :-)
>=20
> So if I've understood correctly, this patch will go to -rc5 and
> the rest will go into net-next?
>=20
> If so, IMHO patch #2 should also go to -rc5. I know it's usually
> frowned up on to add further patches at this late -rc stage, but
> here's my logic:
>=20
> The original driver code just _arbitrarily_ assumed a MAX_TX_URB
> value of 16 parallel transmissions. This value was chosen, it seems,
> because the driver was heavily based on esd_usb2.c and the esd code
> just did so :-(
>=20
> Meanwhile, in the Kvaser hardware at hand, if I've increased the
> driver's max parallel transmissions little above the recommended
> limit reported by firmware, the firmware breaks up badly, reports a
> massive list of internal errors, and the candump traces becomes
> sort of an internal mess hardly related to the actual frames sent
> and received.

In this particular hardware, what's the limit as reported by the firmware=
?

> In my case, I was lucky that the brand we own here (*) had a higher
> max outstanding transmissions value than 16. But if there is hardware

Okay - higher.

> out there with a max oustanding tx support < 16 (#), such hardware
> will break badly under a heavy transmission load :-(

I see.

If you add this motivation to the patch description and let the subject
reflect that this is a "fix" or safety measure rather than a possible
performance improvement, no-one will say anything against this patch :D

> (*) http://www.kvaser.com/products/kvaser-usb-hs-ii-hsls/
>=20
> (#) There are a huge list of Kvaser products having the same controller=

>     but with different performance metrics, so this is quite a
>     possiblity.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--2qmhUb177Bre9NvSD1WK2jO8hxR42OUJE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJVBEylAAoJECte4hHFiupUkwkP/AgRBBYCnitBDyUuH2/FFXxH
RMM1mqx9xiQMnInEdOmNTVcKZR0f1Y9gb3C5fj5BHNbmD5FOLoHGimS3Sk7GtQP1
fq9ppj/1VMRI3jFsqrSDShHi5qpfwQXcFE4522wVGSYvPcXgDKNHxhpAi/6TBAoI
Rxb2W9iG1JhHMQLJgldZNVOaXZ6f1Y3GeQq3DwAMiDhaYoMuXGMVVqPQcZaSnXF7
B6qK1MSNkYBIfqoqL9RYNREVMGumdo3YfWuTDDToUjP14ciWd4SXXThQsgVi6Ve0
WbcT4eq71XudZHa21zssGX3lfYe6LdifAk4wEUBPv0Vxpj9chFRqrEw+PFw5Kyct
1PAbrfry5wVj8FvWP1liCE3qxxIihsAQNyOWZlygYJn9Pq+XdCBMdQBss9Hc3Ym4
jmhAPvOtxg21QAwWZ+TVnRt/hjjLu8NDo0PvcwyzDKgk3KVu2lsYlx3adj4pOlKS
JuFbc/o2Ux58Z59GXPhSOIlUBu484gKo9s4hdMZzk1CkOCFKZSVQk/PZW1NHxBGf
rPT7ytsBwqATgWBRlZNcfPiHO4T7CSMc/vUFSPTr3AAO/tfFdnpgjjFQHhpgIGj5
0ppvxmX/PDntpYcpYqZCRR88fxadFKxYPbXyaayhpV2gIDfsCkgOP/DS7/d6npbi
F5WVL5f+whf6qcEnjUeF
=tbXX
-----END PGP SIGNATURE-----

--2qmhUb177Bre9NvSD1WK2jO8hxR42OUJE--
