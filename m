From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [PATCH] net: dsa: Fix build warning for !PM_SLEEP
Date: Wed, 1 Oct 2014 14:50:01 +0200
Message-ID: <20141001125000.GC21733@ulmo>
References: <1412164740-32452-1-git-send-email-thierry.reding@gmail.com>
 <CAOMZO5DJrvO=mpUEqk+GWFGGU_eNEfn=+XkoL6cqYv+c4GSyZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="+nBD6E3TurpgldQp"
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAOMZO5DJrvO=mpUEqk+GWFGGU_eNEfn=+XkoL6cqYv+c4GSyZw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--+nBD6E3TurpgldQp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 01, 2014 at 09:19:24AM -0300, Fabio Estevam wrote:
> On Wed, Oct 1, 2014 at 8:59 AM, Thierry Reding <thierry.reding@gmail.com>=
 wrote:
> > From: Thierry Reding <treding@nvidia.com>
> >
> > The dsa_switch_suspend() and dsa_switch_resume() functions are only used
> > when PM_SLEEP is enabled, so they need #ifdef CONFIG_PM_SLEEP protection
> > to avoid a compiler warning.
> >
> > Signed-off-by: Thierry Reding <treding@nvidia.com>
> > ---
> >  net/dsa/dsa.c | 2 ++
> >  1 file changed, 2 insertions(+)
> >
> > diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> > index 6905f2d84c44..22f34cf4cb27 100644
> > --- a/net/dsa/dsa.c
> > +++ b/net/dsa/dsa.c
> > @@ -238,6 +238,7 @@ static void dsa_switch_destroy(struct dsa_switch *d=
s)
> >  {
> >  }
> >
> > +#ifdef CONFIG_PM_SLEEP
> >  static int dsa_switch_suspend(struct dsa_switch *ds)
> >  {
> >         int i, ret =3D 0;
> > @@ -280,6 +281,7 @@ static int dsa_switch_resume(struct dsa_switch *ds)
> >
> >         return 0;
> >  }
> > +#endif
>=20
> You could also mark them as __maybe_unused and avoid the ifdef.

The users of these functions, dsa_suspend() and dsa_resume(), also use
the CONFIG_PM_SLEEP protection, so this way is more consistent.

Thierry

--+nBD6E3TurpgldQp
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUK/h4AAoJEN0jrNd/PrOhz24P/jVk3HRnOv40zVn1yld/GXcb
+xib+tP2JkkvmIr77pJsVthNh6k4yvMf8ezfLiTi2yZhAK49QqHEtQGA2ErnFgEx
sCncBfO2X71J6V40T+/eyWalIlOXtPkNw9Zxg+1WsRc6keOw8gMnDxAiTaOun07C
xmY8u23o0a5N5JjrGZxkM8UWevognKDZdLi0DK4qGfCGiMgphXHZfORZqGtqsNcq
LM4nsE7Us1Np4JQPYzYD1NGu6PV4BTEY7jwu3t3W74xAhcN1bIXqabR6Snxmp7q3
eC7/jkvmLn5q8nudejrBCfb/bmpcoemVZL0arbUjWg9orcZXT6sBFz2jj3oLwF+/
ipjDns2PJ3y8HCxOe0BeT63hsFqVJIhoXdAWp01mNUF7ZP2yPVPjZq5nViN7IaKW
J9slfyNhc8KnJSrUNVBgL+YUV1j3ip8bI+WRstdH/jD1xcBEnegRuUR9L9QSxsQ7
LMUWRiWevh+IO0k4SI311z+bfaqhdDqoeNbw6Vf26OW4o0HSsnf61btgpCkyaaye
hZci72T7BueZN28iKlDV1cQItNu7cqEWDsonnzAZwN7KjKXEE2q0WSwhF91g601P
KeLopicur3C7FOM8wV5n9IvBDSRFRN/RdpsGh/KVc5cgNgULiJ0FEWwD0572BAy7
x5LJTze2rGKw+V5W0bwY
=kdd1
-----END PGP SIGNATURE-----

--+nBD6E3TurpgldQp--
