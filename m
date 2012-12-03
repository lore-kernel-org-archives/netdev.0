From: Antonio Quartulli <ordex@autistici.org>
Subject: Re: Re: [B.A.T.M.A.N.] [PATCH] net: fix possible deadlocks in
 rtnl_trylock/unlock
Date: Mon, 3 Dec 2012 21:09:06 +0100
Message-ID: <20121203200906.GJ27828@ritirata.org>
References: <1354382991-31350-1-git-send-email-siwu@hrz.tu-chemnitz.de>
 <1354386972.20109.523.camel@edumazet-glaptop>
 <10264267.HX5FJDguj3@sven-laptop.home.narfation.org>
 <1354391074.20109.527.camel@edumazet-glaptop>
 <20121201200153.GA1002@pandem0nium>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="16qp2B0xu0fRvRD7"
Cc: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	Sven Eckelmann <sven@narfation.org>,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	davem@davemloft.net, Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:31333 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165Ab2LCUJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 15:09:58 -0500
Content-Disposition: inline
In-Reply-To: <20121201200153.GA1002@pandem0nium>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--16qp2B0xu0fRvRD7
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Dec 01, 2012 at 09:01:53PM +0100, Simon Wunderlich wrote:
> On Sat, Dec 01, 2012 at 11:44:34AM -0800, Eric Dumazet wrote:
> > On Sat, 2012-12-01 at 20:04 +0100, Sven Eckelmann wrote:
> > > On Saturday 01 December 2012 10:36:12 Eric Dumazet wrote:
> > > =20
> > > > > diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
> > > > > index c5c0593..c122782 100644
> > > > > --- a/net/bridge/br_sysfs_br.c
> > > > > +++ b/net/bridge/br_sysfs_br.c
> > > > > @@ -142,7 +142,7 @@ static ssize_t store_stp_state(struct device =
*d,
> > > > >=20
> > > > >  	if (!rtnl_trylock())
> > > > >  =09
> > > > >  		return restart_syscall();
> > > > >  =09
> > > > >  	br_stp_set_enabled(br, val);
> > > > >=20
> > > > > -	rtnl_unlock();
> > > > > +	__rtnl_unlock();
> > > > >=20
> > > > >  	return len;
> > > > > =20
> > > > >  }
> > > >=20
> > > > I have no idea of why you believe there is a problem here.
> > > >=20
> > > > Could you explain how net_todo_list could be not empty ?
> > > >=20
> > > > As long as no device is unregistered between
> > > > rtnl_trylock()/rtnl_unlock(), there is no possible deadlock.
> > >=20
> > > I am not sure what "here" means for your. At least batman-adv tries t=
o=20
> > > unregister a device -> problem [1]. I will not make any judgements ab=
out the=20
> > > other uses in the kernel/other parts patched by Simon.
> > >=20
> >=20
> > I was reacting to the change in net/bridge/br_sysfs_br.c
> >=20
> > rtnl_trylock() could set a boolean flag to explicitly WARN_ON()
> > in case we try to unregister a device.
>=20
> Well, I'm not sure if this can happen in the bridge code, but from lookin=
g at the
> code it doesn't appear to be impossible. It would be better to be sure th=
at it can't
> deadlock IMHO.
>=20
> (Although doing unlock/lock/unlock in an unlock function is also a little=
 "uncommon").

But still we have the problem in batman-adv (as Sven pointed out in a previ=
ous
email) that tries to unregister a device in that "critical window".

Exporting __rtnl_unlock() would solve the issue in this case.

If you think the bridge code should not end up in such situation, what if S=
imon
resends the patch with only the __rtnl_unlock() exportation and the change =
in=20
batman-adv?


Cheers,


--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--16qp2B0xu0fRvRD7
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJQvQbiAAoJEADl0hg6qKeOn7YP/RvJOFCkQxhoo36LWrLeBLYE
5Ok0V2i893uyYQWKiobjlJm3SMxsfLRx6orP4z2joST0L2ucH2YPerYnkOD4ds8+
WPkIcX8lTABaAtjrOqiD+bgzAB3hiDEyiktA+jVVnLR5TIMVIPBWzg5HvfYCtQKv
GTkSf0sZA5RxbvOTB/gco+kVWBKnj1YnoPr3jpvGSCIocuabYHBG+sAHhiKUsfxC
pPrQ6S05bjiF6sS2Z07pGdi47x1O7kop5mfX1ciyEeqR4sIC53rx0+lXE5JZ2WU/
phwqjIDV+o4IOIhRyhbNYWj7rCn5jlxwtZea2tV6YJPpiLlMu6M6e/a/lRS13Jqa
MdFAsABaK+OxIX+Ep5/UfHN7G4LhHxrx5WK3oFs7uA7rVxvNz/1czs6qdzjlHsjR
DilROiMuQDM2OzMAEYqJkF4OVW0zLKSulRHDjFT+B/SZQ+1UA+rN9OwWjV6EClzR
lHdYKzOEWXDJoBMtYj/TgLCV6F41uiw9fvqvNwNZOJZgnljPsCt12LNRzC89DnEg
7866CkgcfOeR/E6HcVlLkDDzqjMHsFXA4Zlv9cSOo2vx4ZROsT477YNEfXkLmZ4S
NReBali6P6VuP8J5GerDnsivOCVPGceD9scbN+2INOgZHrpArZYFvpoPAsRjkyfY
t0NC5kxF/Lyr2xAeQzB5
=YSuu
-----END PGP SIGNATURE-----

--16qp2B0xu0fRvRD7--
