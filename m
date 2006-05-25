From: Phil Dibowitz <phil@ipom.com>
Subject: Re: reminder, 2.6.18 window...
Date: Thu, 25 May 2006 10:59:47 -0700
Message-ID: <20060525175947.GA29024@ipom.com>
References: <20060523.182217.59656237.davem@davemloft.net> <4474BD52.6020604@garzik.org> <20060525032357.4990425f.billfink@mindspring.com> <200605250805.38241.bcook@bpointsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="dDRMvlgZJXvWKvBx"
Cc: Bill Fink <billfink@mindspring.com>, Jeff Garzik <jeff@garzik.org>,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpe-24-24-245-191.socal.res.rr.com ([24.24.245.191]:44354 "EHLO
	alt") by vger.kernel.org with ESMTP id S1030231AbWEYR7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 13:59:51 -0400
To: Brent Cook <bcook@bpointsys.com>
Content-Disposition: inline
In-Reply-To: <200605250805.38241.bcook@bpointsys.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 25, 2006 at 08:05:37AM -0500, Brent Cook wrote:
> > I'll admit to not knowing all the intricacies of the kernel coding
> > involved, but I don't offhand see how zeroing the stats would be
> > significantly more complex than updating the stats during normal usage.=
=20
> > But I'll have to leave that argument to the experts.
> >
>=20
> What it boils down to is that currently, a single CPU or thread ever touc=
hes=20
> the stats concurrently, so it doesn't have to lock them or do anything=20
> special to ensure that the continue incrementing. If you want to make sur=
e=20
> that the statistics actually reset when you want them to, you have to acc=
ount=20
> for this case:
>=20
>   CPU0 reads current value from memory (increment)
>   CPU1 writes 0 to current value in memory (reset)
>   CPU0 writes incremented value to memory (increment complete)

Perhaps I'm missing something here, but these counters are only incrimented
in hardware... i.e. attomically.

And the reset I do is via a command register, which should also be atomic.

Now in a driver that was keeping this all in a local struct, I could
understand that need for locking, but in the skge case, and in fact in many
drivers I've looked at, the numbers are all kept in the hardware, increment=
ed
by the hardware, as it gets packets.

So clearing them via command registershouldn't need locking as far as I can
tell.

But please, correct me if I'm wrong.

--=20
Phil Dibowitz                             phil@ipom.com
Freeware and Technical Pages              Insanity Palace of Metallica
http://www.phildev.net/                   http://www.ipom.com/

"They that can give up essential liberty to obtain a little temporary
safety deserve neither liberty nor safety."
 - Benjamin Franklin, 1759


--dDRMvlgZJXvWKvBx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iD4DBQFEdfCTN5XoxaHnMrsRAiPQAJwJgihYir1KYRZZOTVi353KtcP/8gCXXt6e
u+f8EqcUUfLBHnWpQD4GbA==
=L6ew
-----END PGP SIGNATURE-----

--dDRMvlgZJXvWKvBx--
