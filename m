From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH 1/3] netfilter : 3 patches to boost ip_tables performance
Date: Thu, 22 Sep 2005 14:57:24 +0200
Message-ID: <20050922125724.GJ26520@sunbeam.de.gnumonks.org>
References: <432EF0C5.5090908@cosmosbay.com> <200509191948.55333.ak@suse.de>
	<432FDAC5.3040801@cosmosbay.com> <200509201830.20689.ak@suse.de>
	<433082DE.3060308@cosmosbay.com> <43308324.70403@cosmosbay.com>
	<4331D0A9.3080801@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Encpt1P6Mxii2VuT"
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	linux-kernel@vger.kernel.org, Andi Kleen <ak@suse.de>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <4331D0A9.3080801@cosmosbay.com>
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


--Encpt1P6Mxii2VuT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 21, 2005 at 11:29:13PM +0200, Eric Dumazet wrote:
> Patch 1/3
>=20
> 1) No more one rwlock_t protecting the 'curtain'

I have no problem with this change "per se", but with the
implementation.

As of now, we live without any ugly #ifdef CONFIG_SMP / #endif sections
in the code - and if possible, I would continue this good tradition.

For example the get_counters() function.  Wouldn't all the smp specific
code (for_each_cpu(), ...)  be #defined to nothing anyway?

And if we really need the #ifdef's, I would appreciate if those
sectionas are as small as possible.  in get_counters() the section can
definitely be smaller, rather than basically having the whole function
body separate for smp and non-smp cases.

Also, how much would we loose in runtime performance if we were using a
"rwlock_t *" even in the UP case?.  I mean, it's just one more pointer
dereference of something that is expected to be in cache anyway, isn't
it?  This gets rid of another huge set of #ifdefs that make the code
unreadable and prone to errors being introduced later on.

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--Encpt1P6Mxii2VuT
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDMqo0XaXGVTD0i/8RAqmfAJ4wK16fo/z10f3AhLri+4P+LemXVACdFrDh
kp2OtLw2758hy9k1bsfZZuY=
=Plu3
-----END PGP SIGNATURE-----

--Encpt1P6Mxii2VuT--
