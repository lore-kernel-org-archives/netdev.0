From: mcgrof@studorgs.rutgers.edu (Luis R. Rodriguez)
Subject: Re: [PATCH Linux-2.6.8-rc1] prism54 Fix initialization with older firmware
Date: Thu, 22 Jul 2004 06:42:49 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040722104249.GD9141__6074.08823348141$1090515511$gmane$org@ruslug.rutgers.edu>
References: <200407221027.33023.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="t0UkRYy7tHLRMCai"
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Margit Schubert-While <margitsw@t-online.de>
Content-Disposition: inline
In-Reply-To: <200407221027.33023.margitsw@t-online.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--t0UkRYy7tHLRMCai
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 22, 2004 at 10:27:32AM +0200, Margit Schubert-While wrote:
> 2004-07-22 Margit Schubert-While <margitsw@t-online.de>
>=20
> * In the card initialization routine, we try to set the
>   output power. For firmware < 1.0.4.3, this leads to a
>   worrying "mgt_commit has failed .." in the log although
>   the device continues to react normally.
>   Fix is simple, do not try to configure output power.
>   (which I believe we should not be doing anyway as it is=20
>    probably against local country regulations)
>=20
> Margit

Margit, I think we should rather detect the version of the firmware and
depending on this decide what to do.

A quick test proves you can obtain firmware verion from

[OID_INL_VERSION] =3D {0xFF020005, 0, 8, OID_TYPE_RAW},

Then somewhere,

union oid_res_t r;
char *ver;

mgt_get_request(priv, OID_INL_VERSION, 0, NULL, &r);
ver =3D (char *) r.ptr;
printk(KERN_DEBUG "Version: %s\n", ver);

This will either be 1.0.4.3.arm or 1.0.3.0.arm. You can then strcmp and
do the right thing. I'd finish this work up but I'm busy with WPA.

	Luis

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--t0UkRYy7tHLRMCai
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFA/5opat1JN+IKUl4RAoDPAJ9Et3OLSiiOrqAbS1fEYietbCFNXwCfd4PY
eWfJM2DRTu2H2lCJBNe0qdQ=
=6EcK
-----END PGP SIGNATURE-----

--t0UkRYy7tHLRMCai--
