From: Daniel Stone <daniel@fooishbar.org>
Subject: Re: net/ipv4/route.c GC patch: is this insane?b4Db3tL
Date: Mon, 31 May 2004 22:26:08 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040531122608.GR24955@fooishbar.org>
References: <20040530151434.GE24955@fooishbar.org> <16571.9006.703294.10134@robur.slu.se>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="i0LFOk513GRb+T2w"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <16571.9006.703294.10134@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--i0LFOk513GRb+T2w
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, May 31, 2004 at 02:21:02PM +0200, Robert Olsson wrote:
> Daniel Stone writes:
>  > Hi guys,
>  > Attached is a patch to net/ipv4/route.c (against 2.4.23, sorry) to
>  > combat the 'dst cache full' issue. Essentially, there's a machine that=
 I
>  > have access to (a router) that will report 'dst cache full', and
>  > immediately cease dealing with any IPv4 traffic. I found the attached
>  > patch against 2.0, and forward-ported it to 2.4. As this issue only
>  > crops up randomly every couple of weeks, I can't tell you whether it's
>  > worked or not. All I know is that it hasn't eaten my firstborn so far:
>  > given a quick spin, it seemed to work OK, but whether or not it solves
>  > the problem is a different matter.
>=20
>  Hello!
>=20
>  If your traffic is sane and you got dst cache overflow you should=20
>  probably try to reduce gc_min_interval so your GC can release a=20
>  higher numbers of dst entries per second. Flushing active entries
>  means that they are created again. This decreases your throughput
>  maybe just enough not to reach the limit where you reach overflow.

gc_min_interval was zero - should this increase, or what?.

>  > +	atomic_set(&ipv4_dst_ops.entries, 0);
>=20
>  These counters should only be handled by the freeing process rt_free etc.

OK.

Thanks for the pointers!
:) d

--=20
Daniel Stone                                              <daniel@fooishbar=
=2Eorg>
"The programs are documented fully by _The Rise and Fall of a Fooish Bar_,
available by the Info system." -- debian/manpage.sgml.ex, dh_make template

--i0LFOk513GRb+T2w
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAuyRgcPClnTztfv0RAuqqAJ4hDo6Sm+ugRvkNJU3LdLFzv2rMVwCgkfzy
0sU/sGsPLQANjdJ1TFFN+h8=
=tN4T
-----END PGP SIGNATURE-----

--i0LFOk513GRb+T2w--
