From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH + RFC] neighbour/ARP cache scalability
Date: Wed, 22 Sep 2004 13:14:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922111447.GP3236@sunbeam.de.gnumonks.org>
References: <20040920225140.GH1307@sunbeam.de.gnumonks.org> <20040921203118.734a0a7e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="nccO0ldXW0cuDU6a"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040921203118.734a0a7e.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--nccO0ldXW0cuDU6a
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 21, 2004 at 08:31:18PM -0700, David S. Miller wrote:
=20
> Ok Harald, I did some snooping around and here is what
> I've come up with.

Thanks for digging into this issue.

> 1) We have 5 or 6 implementations of "walk neighbour hash
>    table in sequence", that's rediculious and is the only
>    reason that hashtable layout or number of entries is
>    even known by code outside of net/core/neighbour.c
> [...]
> 1.5) tbl->ops->hash() should return the raw hash, the caller
>      will do the necessary masking.
> [...]
>=20
> 2) We should size these hash table dynamically, growing them
>    at neigh_create() time.

great, that sounds like a scalable approach.  I'm looking forward to
reading through the code :)

> 3) If we have a sysctl for this stuff at all, it will be for
>    the limit of the hash table growth, but I don't think that
>    is necessary given #2

But we will still have the existing sysctls for the garbage collector, I
guess (like gc_thresh*). =20

And I still want to address the "all complete entries flushed due to
lots of bogus incomplete entires" issue somehow.  As stated before, I
have seen this on happen on live systems. =20

Do you agree that this is an existing problem?

I think just having a certain 'reserve' for complete entries (or a let's
say 80% limit for incomplete ones) should address this issue.

btw: I guess you're implementing this as 2.6.x only patch.  Once you're
finished, I'll have to do a 2.4.x backport anyway [for business reasons
*g*].  So don't bother doing that, I'll post the patch here (which
doesn't imply that I want to have it merged mainline).

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--nccO0ldXW0cuDU6a
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBUV6nXaXGVTD0i/8RAj2vAKCSr1GNraXld1/8enzBtqwpqXz2PQCgoDjl
Yc58z9aa9wUR9s7ELYJEKoc=
=88zI
-----END PGP SIGNATURE-----

--nccO0ldXW0cuDU6a--
