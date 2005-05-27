From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH 2.6] fix deadlock with ip_queue and tcp local input path
Date: Fri, 27 May 2005 09:37:58 +0200
Message-ID: <20050527073758.GP13114@sunbeam.de.gnumonks.org>
References: <20050526142420.GD13114@sunbeam.de.gnumonks.org>
	<E1DbQ49-00027X-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jZB9q6GuZX3GwDM8"
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1DbQ49-00027X-00@gondolin.me.apana.org.au>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--jZB9q6GuZX3GwDM8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, May 27, 2005 at 07:38:57AM +1000, Herbert Xu wrote:
> Harald Welte <laforge@netfilter.org> wrote:
> >=20
> > The patch below adds an additional queue for ip_queue verdicts.  They
> > come up from userspace, are appended to a queue which is then processed
> > by a tasklet.  The tasklet itself runs in softirq context, so when timer
> > hardirq leaves, no tcp_delack_timer() will be executed until
> > nf_reinject() has finished.
>=20
> This seems to be overly complicated if all you want is to do this in
> softirq context.  What's wrong with simply alling local_bh_disable?

Patrick just pointed this out, too.  I wasn't sure whether
local_bh_disable() would make the context really look like softirq in
every way.  If yes, it would certainly solve the problem, because
in_interrupt() at hardirq-exit would be true and therefore the timer
softirq not scheduled immediately.

I'll have Astaro test this variant.

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--jZB9q6GuZX3GwDM8
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFCls5WXaXGVTD0i/8RAirAAJ0eBAjVnXz0+Zp8gWdE+PhO4eo/8QCgkCDe
4Ebn9SthXHgUo8ru+LcvF6o=
=jQus
-----END PGP SIGNATURE-----

--jZB9q6GuZX3GwDM8--
