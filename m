From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH + RFC] neighbour/ARP cache scalability
Date: Tue, 21 Sep 2004 15:49:18 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921134918.GK1307@sunbeam.de.gnumonks.org>
References: <20040920225140.GH1307@sunbeam.de.gnumonks.org> <Pine.LNX.4.44.0409211412580.1570-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="wRyyN4gAPkNkeCwp"
Cc: Linux Netdev List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0409211412580.1570-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--wRyyN4gAPkNkeCwp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 21, 2004 at 02:19:52PM +0300, Pekka Savola wrote:
> On Tue, 21 Sep 2004, Harald Welte wrote:
> > 1) should I try to use jhash for ipv6, too?
> >=20
> > 2) Dave has indicated that there should be an upper limit for hash
> >    buckets.  What is considered a reasonable upper bound, even for very
> >    large systems?
> [...]
> > 5) What is the proposed solution for IPv6, when you have /48 or /64 bit
> >    prefixes and systems become even more vulnerable to neighbour cache
> >    attacks? =20
>=20
> The situation with IPv6 is not much different than with IPv4.

I disagree (see below).

> It's better in the sense that nobody will be portscanning the whole=20
> address space or subnets as a means to look for nodes. =20

I agree, but people will do it as a means to DoS the routers...

> So, the viruses, worms, exploits etc. will need to use other
> techniques, so the practical need is lower. >=20

Just because worms cannot use this mechanism anymore doesn't mean that
it will not happen, initiated manually by somebody who wants to DoS your
routers.

> It's worse in the sense that there is more space in each subnet for
> doing aggressive probing -- but this may not be a big issue with a
> good algorithm and a threshold.

So what is that 'good algorithm'.  The current Linux algorithm is from
my point of view (only tested with ipv4) not very good when it comes to
high numbers of neighbours.

> In short, I don't think there needs to be anything special for IPv6. =20
> Just the same mechanisms as for IPv4 -- at some threshold, start=20
> garbage collecting more aggressively, using a "least-recently-used"=20
> algorithm (or the like).=20

Yes, but let's assume somebody floods you with 100MBit wirespeed, that's
148kpps, meaning you will have to have a limit of at least 148.800 plus
the number of 'real' hosts directly attached to your system in order to
cope with this.  Otherwise you will end up having all your neighbour
cache entries filled with INCOMPLETE entries, whose retrans_time of 1HZ
is not reached yet.

To do some quick calculations, this would require some 23.8 MByte RAM on
a 32bit platform(!)

Now what if you have multiple interfaces, or you start thinking about
gigabit ethernet...

> To constraint remote resource exhaustion exploits please make sure=20
> that the algorithm is sufficiently can also deal with the threat=20
> described at RFC 3756 section 4.3.2.

Isn't that exactly what we're talking about?
To quote from that RFC:

  In a way, this problem is fairly similar to the TCP SYN flooding
  problem.  For example, rate limiting Neighbor Solicitations,
  restricting the amount of state reserved for unresolved
  solicitations, and clever cache management may be applied.

So they encourage limiting the number of unresolved solicitations.  We
don't do that at this point, and allow all of the neighbour cache be
filled with them...

> Pekka Savola                 "You each name yourselves king, yet the

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--wRyyN4gAPkNkeCwp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBUDFeXaXGVTD0i/8RAm7dAKCgTXhCF1A3RLEoL/KDizf47mRSUQCgqzAP
pRV+fw0QhMDn2SLp92D+ASw=
=6GBo
-----END PGP SIGNATURE-----

--wRyyN4gAPkNkeCwp--
