From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 1/2] net: ethernet: sxgbe: remove private tx queue lock
Date: Thu, 15 Dec 2016 22:03:24 +0100
Message-ID: <20161215210324.GA13878@amd>
References: <1481141138-19466-1-git-send-email-LinoSanfilippo@gmx.de>
 <1481141138-19466-2-git-send-email-LinoSanfilippo@gmx.de>
 <20161207231534.GB5889@electric-eye.fr.zoreil.com>
 <051e3043-8b58-0591-36e3-99e2267f67f4@gmx.de>
 <20161208231943.GA13102@electric-eye.fr.zoreil.com>
 <20161209112142.GA22710@amd>
 <c76124b9-6376-42b9-2821-b5a8185f5034@gmx.de>
 <20161211201104.GB20574@amd>
 <cfad6b84-de23-2e03-6d34-2b3451975179@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="r5Pyd7+fXNt84Ff3"
Cc: Francois Romieu <romieu@fr.zoreil.com>, bh74.an@samsung.com,
        ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cfad6b84-de23-2e03-6d34-2b3451975179@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> sorry for the late reply.

No problem. Thanks for the help.

> On 11.12.2016 21:11, Pavel Machek wrote:
> >=20
> > Do you understand what stmmac_tx_err(priv); is supposed to do? In
> > particular, if it is called while the driver is working ok -- should
> > the driver survive that?
>=20
> As far as I understood it is supposed to fixup an errorneous tx path, e.g=
=2E a
> missing tx completion for transmitted frames.
>=20
> Some drivers do this by restarting only the HW parts responsible for tx, =
some
> others by restarting the complete hardware.=20
> But IMO it should also be ok to be called if the HW is still working fine.
>=20
> > Because it does not currently, and I don't know how to test that
> > code. Unplugging the cable does not provoke that.
> >=20
> > I tried
> >=20
> >         } else if (unlikely(status =3D=3D tx_hard_error))
> >                 stmmac_tx_err(priv);
> > +
> > +       {
> > +               static int i;
> > +               i++;
> > +               if (i=3D=3D1000) {
> > +                       i =3D 0;
> > +                       printk("Simulated error\n");
> > +                       stmmac_tx_err(priv);
> > +               }
> > +       }
> >  }
> >=20
>=20
> Ok, there is this race that Francois mentioned so it is not surprising th=
at
> the driver does not survive the call of stmmac_tx_err() as it is called n=
ow.
> Thats why I suggested to do a proper shutdown and restart of the tx path =
to
> avoid the race.

I actually did experiment with adding locking there, too, and no, no
luck. It seems stmmac_tx_err() is more broken than just locking.

Best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--r5Pyd7+fXNt84Ff3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhTBRwACgkQMOfwapXb+vLjdgCfc26JTE5nPbSz13IfWQT2KN14
GWsAoJoSAAm1YDswwUtkhOCwRICOtNoo
=srQD
-----END PGP SIGNATURE-----

--r5Pyd7+fXNt84Ff3--
