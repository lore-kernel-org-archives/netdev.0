From: Martijn van Oosterhout <kleptog@svana.org>
Subject: Re: PPP-over-L2TP kernel support, patch for review
Date: Wed, 8 Sep 2004 19:04:55 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040908090455.GF18285@svana.org>
References: <20040908073238.GB18285@svana.org> <E1C4xe9-0005xL-00@gondolin.me.apana.org.au> <20040908083828.GE18285@svana.org> <20040908084630.GA23117@gondor.apana.org.au>
Reply-To: Martijn van Oosterhout <kleptog@svana.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="TeJTyD9hb8KJN2Jy"
Cc: davem@davemloft.net, jchapman@katalix.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20040908084630.GA23117@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--TeJTyD9hb8KJN2Jy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 08, 2004 at 06:46:30PM +1000, Herbert Xu wrote:
> It can break because people often initialise the size of the
> address by doing sizeof(struct sockaddr_pppox).  For example,
> you'll see exactly this breakage in pppoe_getname in
> drivers/net/pppoe.c.

/me looks... *BLINK* Ugh, getname takes a length argument but it's
write only.

So, hypothetically, if I get passed a file descriptor through a UNIX
domain socket and do a getname on it, there is no way to guarentee that
it won't go past the buffer I've allocated. Who came up with this lame
API?

> IMHO this union was a silly idea to begin with.  Let's not prolong
> its life any further.

Well, I guess I'll have to agree to that. So, lets say we create two
new types, one for each version of the union, sockaddr_pppox_pppoe and
sockaddr_pppox_pppol2tp. Deprecate the current sockaddr_pppox
altogether (can't get rid of it now). Possibly create a new
sockaddr_pppox_generic for use in the actual pppox.c file. Sprinkle
some typecasts around to make the compiler happy and voila!

Then future userspace programs can use the structure appropriate for
them. Does removing the union change the alignment on any
architechture? Or will the dummy union have to stay in perpituity?

Seems fairly straight forward... I'll see if I have time to whip
something up...
--=20
Martijn van Oosterhout   <kleptog@svana.org>   http://svana.org/kleptog/
> Patent. n. Genius is 5% inspiration and 95% perspiration. A patent is a
> tool for doing 5% of the work and then sitting around waiting for someone
> else to do the other 95% so you can sue them.

--TeJTyD9hb8KJN2Jy
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQFBPss3Y5Twig3Ge+YRAhNmAJ48pJZ5IKRSCFfECvL7hyXWA7/aPQCgtewS
wmps98B3eRCfPfHHVbzrhpc=
=CiBP
-----END PGP SIGNATURE-----

--TeJTyD9hb8KJN2Jy--
