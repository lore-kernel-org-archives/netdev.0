From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 1/2] net: ethernet: sxgbe: remove private tx queue lock
Date: Fri, 9 Dec 2016 12:21:42 +0100
Message-ID: <20161209112142.GA22710@amd>
References: <1481141138-19466-1-git-send-email-LinoSanfilippo@gmx.de>
 <1481141138-19466-2-git-send-email-LinoSanfilippo@gmx.de>
 <20161207231534.GB5889@electric-eye.fr.zoreil.com>
 <051e3043-8b58-0591-36e3-99e2267f67f4@gmx.de>
 <20161208231943.GA13102@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="Qxx1br4bt0+wmkIi"
Cc: Lino Sanfilippo <LinoSanfilippo@gmx.de>, bh74.an@samsung.com,
        ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161208231943.GA13102@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri 2016-12-09 00:19:43, Francois Romieu wrote:
> Lino Sanfilippo <LinoSanfilippo@gmx.de> :
> [...]
> > OTOH Pavel said that he actually could produce a deadlock. Now I wonder=
 if
> > this is caused by that locking scheme (in a way I have not figured out =
yet)
> > or if it is a different issue.
>=20
> stmmac_tx_err races with stmmac_xmit.

Umm, yes, that looks real.

And that means that removing tx_lock will not be completely trivial
:-(. Lino, any ideas there?

netif_tx_lock_irqsave() would help, but afaict that one does not
exist.

Plus, does someone know how to trigger the status =3D=3D tx_hard_error? I
tried powering down the switch, but that did not do it.

Thanks,								Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--Qxx1br4bt0+wmkIi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhKk8YACgkQMOfwapXb+vLocACfTaap2OrkY4NgnOJcI5lw8TUN
XQYAoI9f7Pme97uFmWAj1ZrKo4MBuui2
=SKKt
-----END PGP SIGNATURE-----

--Qxx1br4bt0+wmkIi--
