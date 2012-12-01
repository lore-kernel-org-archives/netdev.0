From: Simon Wunderlich <simon.wunderlich-Y4E02TeZ33kaBlGTGt4zH4SGEyLTKazZ@public.gmane.org>
Subject: Re: [PATCH] net: fix possible deadlocks in
 rtnl_trylock/unlock
Date: Sat, 1 Dec 2012 21:01:53 +0100
Message-ID: <20121201200153.GA1002@pandem0nium>
References: <1354382991-31350-1-git-send-email-siwu@hrz.tu-chemnitz.de>
 <1354386972.20109.523.camel@edumazet-glaptop>
 <10264267.HX5FJDguj3@sven-laptop.home.narfation.org>
 <1354391074.20109.527.camel@edumazet-glaptop>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature"; boundary="opJtzjQTFsWo+cga"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1354391074.20109.527.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Dec 01, 2012 at 11:44:34AM -0800, Eric Dumazet wrote:
> On Sat, 2012-12-01 at 20:04 +0100, Sven Eckelmann wrote:
> > On Saturday 01 December 2012 10:36:12 Eric Dumazet wrote:
> > =20
> > > > diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
> > > > index c5c0593..c122782 100644
> > > > --- a/net/bridge/br_sysfs_br.c
> > > > +++ b/net/bridge/br_sysfs_br.c
> > > > @@ -142,7 +142,7 @@ static ssize_t store_stp_state(struct device *d,
> > > >=20
> > > >  	if (!rtnl_trylock())
> > > >  =09
> > > >  		return restart_syscall();
> > > >  =09
> > > >  	br_stp_set_enabled(br, val);
> > > >=20
> > > > -	rtnl_unlock();
> > > > +	__rtnl_unlock();
> > > >=20
> > > >  	return len;
> > > > =20
> > > >  }
> > >=20
> > > I have no idea of why you believe there is a problem here.
> > >=20
> > > Could you explain how net_todo_list could be not empty ?
> > >=20
> > > As long as no device is unregistered between
> > > rtnl_trylock()/rtnl_unlock(), there is no possible deadlock.
> >=20
> > I am not sure what "here" means for your. At least batman-adv tries to=
=20
> > unregister a device -> problem [1]. I will not make any judgements abou=
t the=20
> > other uses in the kernel/other parts patched by Simon.
> >=20
>=20
> I was reacting to the change in net/bridge/br_sysfs_br.c
>=20
> rtnl_trylock() could set a boolean flag to explicitly WARN_ON()
> in case we try to unregister a device.

Well, I'm not sure if this can happen in the bridge code, but from looking =
at the
code it doesn't appear to be impossible. It would be better to be sure that=
 it can't
deadlock IMHO.

(Although doing unlock/lock/unlock in an unlock function is also a little "=
uncommon").

Cheers,
	Simon

--opJtzjQTFsWo+cga
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAlC6YjEACgkQrzg/fFk7axbObgCbB8uw+Z/LRv4sx5AiDwyL88zs
qgcAoLMu45lKXDgn7O8L5oLtaUwJkEjU
=oBAV
-----END PGP SIGNATURE-----

--opJtzjQTFsWo+cga--
