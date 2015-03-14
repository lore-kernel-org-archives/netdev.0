From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4 1/3] can: kvaser_usb: Fix tx queue start/stop
 race conditions
Date: Sat, 14 Mar 2015 14:41:18 +0100
Message-ID: <55043A7E.7040001@pengutronix.de>
References: <20150226152011.GA6075@linux> <20150314130249.GA20796@linux>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="T0Disu2qDKV6T2483GCnm86P046P1hImu"
Cc: Linux-CAN <linux-can@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: "Ahmed S. Darwish" <darwish.07@gmail.com>,
	Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andri Yngvason <andri.yngvason@marel.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20150314130249.GA20796@linux>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--T0Disu2qDKV6T2483GCnm86P046P1hImu
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/14/2015 02:02 PM, Ahmed S. Darwish wrote:
> From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
>=20
> A number of tx queue wake-up events went missing due to the
> outlined scenario below. Start state is a pool of 16 tx URBs,
> active tx_urbs count =3D 15, with the netdev tx queue open.
>=20
> CPU #1 [softirq]                         CPU #2 [softirq]
> start_xmit()                             tx_acknowledge()
> ................                         ................
>=20
> atomic_inc(&tx_urbs);
> if (atomic_read(&tx_urbs) >=3D 16) {
>                         -->
>                                          atomic_dec(&tx_urbs);
>                                          netif_wake_queue();
>                                          return;
>                         <--
>     netif_stop_queue();
> }
>=20
> At the end, the correct state expected is a 15 tx_urbs count
> value with the tx queue state _open_. Due to the race, we get
> the same tx_urbs value but with the tx queue state _stopped_.
> The wake-up event is completely lost.
>=20
> Thus avoid hand-rolled concurrency mechanisms and use a proper
> lock for contexts and tx queue protection.
>=20
> Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>

Applied to can. This will go into David's net tree and finally into
net-next. Then I'll apply patches 2+3. Nag me, if I forget about them ;)

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--T0Disu2qDKV6T2483GCnm86P046P1hImu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJVBDqBAAoJECte4hHFiupUw90QAIQ7cAJoZEsCBdvj7CCJRJsT
/VHAnHhh8sm00n2u1/HmeJSrSwq/Bi4Cc4lOrirXpQbkz2xnJDay586aJet5aIxY
HTZLqKnKamPwNBl3II4xeLkgNHqsDNadulfD3qB8GcH6oI6Qb9NjM+MqzTPMeFhr
bfux7VNJvgOn44m+vMcb9+e6dUPacNJp0kjZqwI06Eu/dsYweCmBVysST+3zdbX/
0y+9om+0AFrbU5z/mv1WRRgb8jquZaoy6rfYmv4+/yMK6f8ZK/MlWbQybOmLN9LB
E8oR/ZhghFrvVwbZ4y6G2gg22ScmqeyntlILtLy/z8ovU5Hem+YxCctuTFfg2ByO
AIH+FRJTI9/AFv4nfB5f5FrVasE6RA/jZs5yS0POJisrvX84VBJNEFsWVcHOeghN
CfJRU7qgVk31kdb4DTHkKsZLqgJ2Da4cg6JANpROQeuELzpLfGy5+qLk3BZO6Wz3
QCiWKqjcfE819OiAfi3uZBpvYmnSLU9s88Et9osLVmQRLB5/gnOGuTQ2Xz1YZVUK
+uABDB8QVsfxBHqexcOBMnbsPU57SIt0DOo7UP0GgOHFdHtvpyA26Y/bHqYvAVRh
bIjcw4UwFaJIFv/cBXsGVjSogK/QnuYney4NFPGSHmhE5cQdI+gDMX41ELQdf/+e
+64K4uWooBzg2x0y4Jfi
=4lio
-----END PGP SIGNATURE-----

--T0Disu2qDKV6T2483GCnm86P046P1hImu--
