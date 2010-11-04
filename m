From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: Freeing alive fib_info caused by ebc0ffae5
Date: Thu, 04 Nov 2010 22:23:51 +1100
Message-ID: <1288869831.30549.12.camel@concordia>
References: <1288866186.30549.10.camel@concordia>
	 <1288866626.2659.71.camel@edumazet-laptop>
	 <1288869699.2659.77.camel@edumazet-laptop>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-uRxgknf3QURcdIjRL0wx"
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:39773 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753736Ab0KDLXx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Nov 2010 07:23:53 -0400
In-Reply-To: <1288869699.2659.77.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-uRxgknf3QURcdIjRL0wx
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2010-11-04 at 12:21 +0100, Eric Dumazet wrote:
> Le jeudi 04 novembre 2010 =C3=A0 11:30 +0100, Eric Dumazet a =C3=A9crit :
> > Le jeudi 04 novembre 2010 =C3=A0 21:23 +1100, Michael Ellerman a =C3=A9=
crit :
> > > Hi all,
> > >=20
> > > I'm running Linus' latest or thereabouts (ff8b16d), and I'm seeing
> > > "Freeing alive fib_info" messages, from free_fib_info().
> > >=20
> > > Actually I only get one per boot, when network interfaces come up.
> > > Seemingly related I am getting refcount problems when I shutdown, ie.
> > > unregister_netdevice() sees a usage count of 1, which never decrement=
s.
> > >=20
> > > Bisect says it's ebc0ffae5 which causes the problem, or makes it appe=
ar.
> > >=20
> > >     fib: RCU conversion of fib_lookup()
> > >    =20
> > >     fib_lookup() converted to be called in RCU protected context, no
> > >     reference taken and released on a contended cache line (fib_clntr=
ef)
> > >    =20
> > >=20
> > > Is this a bug in that commit, or a driver bug exposed?
> >=20
> > Hi Michael, thanks for the report (and painful bisection I guess)
> >=20
> > Thats hard to say... Is it reproductable on my machine ?
> >=20
>=20
> Hmm, a review of the code spotted a bug in fib_result_assign()

Aha, I was just adding some debug in there. Let me test the patch.

cheers


--=-uRxgknf3QURcdIjRL0wx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAkzSl8cACgkQdSjSd0sB4dLviQCeL/kTPRTGKM0fKBwYKtJTJsze
nhYAn1V2aYjSY1s4COuiUfQS/VyxbyTA
=w+0q
-----END PGP SIGNATURE-----

--=-uRxgknf3QURcdIjRL0wx--

