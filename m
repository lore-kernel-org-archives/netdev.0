From: Martijn van Oosterhout <kleptog@svana.org>
Subject: Re: PPP-over-L2TP kernel support, patch for review
Date: Wed, 8 Sep 2004 18:38:28 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040908083828.GE18285@svana.org>
References: <20040908073238.GB18285@svana.org> <E1C4xe9-0005xL-00@gondolin.me.apana.org.au>
Reply-To: Martijn van Oosterhout <kleptog@svana.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vmttodhTwj0NAgWp"
Cc: davem@davemloft.net, jchapman@katalix.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1C4xe9-0005xL-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--vmttodhTwj0NAgWp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 08, 2004 at 06:17:41PM +1000, Herbert Xu wrote:
> Martijn van Oosterhout <kleptog@svana.org> wrote:
> > So the answer is: I think so. However, I'm not sure why this is an
> > issue. struct sockaddr is passed back and forth between userspace and
> > kernelspace has many varying sizes (sockaddr_un is quite large). What
> > could be affected? getsockname, connect and bind all take a length
> > argument. Or are you referring to the possibility of it affecting other
> > structures it's embedded in?
>=20
> Any existing user-space binary that has struct sockaddr_pppox in it will
> be broken by your change.
>=20
> Perhaps you can create a new sockaddr type?

But within a single binary, it knows how big the structure was at the
time it was compiled and has allocated the appropriate space. It also
was compiled with a particular version of PX_MAX_PROTO so it should
know if it's an unknown type. Any communication with the kernel
includes the size so there is no possibility of buffer overruns AFAICS.
The change is backward compatable in the sense that the sa_protocol
field determines which union member is appropriate and hence the
expected size of the structure.

However, it's possible I've not thought of a failure case. Maybe some
parts of kernel or userspace ignore the length or sa_protocol argument.

It's possible to create a new sockaddr type. I didn't do that as I
thought the point was to have all PPPoX sockets to use the same type.
You could create a socket type sockaddr_pppox2 which is bigger than the
current sockaddr_pppox but otherwise identical. Change the kernel to
use this new structure (no actual code changes needed, just argument
types). Worst case we get a new structure for each new type of PPPoX
socket. The AF_PPPOX will be the same for all of them.

Transistion userspace to use the new pppox2 structure for everything
and you're done. Again, no code changes required, only the type is
changed.

I can create a patch if you want...
--=20
Martijn van Oosterhout   <kleptog@svana.org>   http://svana.org/kleptog/
> Patent. n. Genius is 5% inspiration and 95% perspiration. A patent is a
> tool for doing 5% of the work and then sitting around waiting for someone
> else to do the other 95% so you can sue them.

--vmttodhTwj0NAgWp
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQFBPsUEY5Twig3Ge+YRAgDdAKCWWXVGbxoO4qXQjXSCoaCR64DR3ACePlXR
XVSB6XhySEtHEi04Ns1zeRM=
=h1Da
-----END PGP SIGNATURE-----

--vmttodhTwj0NAgWp--
