From: Felipe Balbi <balbi@ti.com>
Subject: Re: [net PATCH 1/1] drivers: net: cpsw: fix disabling of tx
 interrupt in rx isr
Date: Wed, 8 Jul 2015 02:38:55 -0500
Message-ID: <20150708073855.GA7277@saruman.tx.rr.com>
References: <1436338066-7685-1-git-send-email-mugunthanvnm@ti.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="+QahgC5+KEYLbs62"
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	Felipe Balbi <balbi@ti.com>, <stable@vger.kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1436338066-7685-1-git-send-email-mugunthanvnm@ti.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--+QahgC5+KEYLbs62
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Wed, Jul 08, 2015 at 12:17:46PM +0530, Mugunthan V N wrote:
> With the below commit, common isr is split into tx and rx, but in
> rx isr tx interrupt is also disabled. So tx packets are not handled
> during rx interrupts and rx napi completion. Fixing by disabling on
> rx interrupt in rx isr.
>=20
> Fixes: c03abd84634d ("net: ethernet: cpsw: don't requests IRQs we don't u=
se")

why does this fix that commit ? What was the regression ? So RX IRQ fire
and both RX and TX are disabled, sure that's bad. But it should cause
lower throughput. At a minimum, I think your commit log needs some work.

Also, disable_irq_nosync() shouldn't really be needed, you could just
mask the IRQ in the IRQ Enable register, but I guess that'd be v4.3
material.

--=20
balbi

--+QahgC5+KEYLbs62
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVnNOPAAoJEIaOsuA1yqREw/gQAJ/C48Gr2LQSzqCACexAbBWY
1Qz6qa+mvLjbL6TjKuMcKDBjVdHVSffTXGBTl/C9X2PXZqci51otaDrJ9tPS0fbD
ciNx5bh6xGynINEbXkkpIENR3LKj1N3crzMhrURuJKWXY7pPt4JYjb876jjmPBjp
zMdZ9AceX0RGSVpE+iui08L3QA8Uu7bjX20oOh6Ju+Qop+2vyuO2XcG0d5DQpDks
kISGJJ7MYACJYRr2UEzAD0v+O+P1D+mPR/voLojoXYxcfsGGmM+k66Igv4d5ZxRS
hGnukkAZhXYfglpOEB+GE1uQr5laC+liK9ElOK968+9LaPTL2U66TAA5MOFC12f8
bqq8XrBfiit/k3jctRFzPaF5RKBt4o4ivS7nzZs8wEkKwdHXzjinAbd8crI8VYBH
ooVQQST2Ds9qMTcYkBhBhB2mpRQG54urcjIa7uKNKNtOu83TsQAfU6lsI0zCbBb5
MIe/jXqiNhjFHehJFzwPwVf5qDPV82gZCw4+vDOjqv5YavlG0P+Vv55Dq22bEMBs
vIJps9/fgFqn6uHThl1HV0kx1aPH4lkw50lu9xoRdNNoPBnG/UyXRPped9P400Gk
0YciqOzubaZR4R5hQyL5SRPHzXoO97DAZMq7J974uPoLjXGQMCFZPsEcU3+D9+9x
aDnJKrGGFNHYo63hRQ7H
=guSF
-----END PGP SIGNATURE-----

--+QahgC5+KEYLbs62--
