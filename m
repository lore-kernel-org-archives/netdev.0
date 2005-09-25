From: Harald Welte <laforge@gnumonks.org>
Subject: Re: rwlock recursion on CPU#0, netfilter related?
Date: Sun, 25 Sep 2005 15:43:44 +0200
Message-ID: <20050925134344.GJ731@sunbeam.de.gnumonks.org>
References: <20050925105834.GA15243@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OOApBOWN8PWHaZPG"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Pietikainen <pp@ee.oulu.fi>
Content-Disposition: inline
In-Reply-To: <20050925105834.GA15243@ee.oulu.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--OOApBOWN8PWHaZPG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Sep 25, 2005 at 01:58:34PM +0300, Pekka Pietikainen wrote:
> Just to get a wider audience, somewhere between 2.6.13-git4 and current=
=20
> (2.6.14-rc2-git4 is the last one I tested, which seems to have some
> fixes in this are wrt. git3, but problem remains) my x86_64
> crashes quite quickly after boot. Using Fedora devel kernels, I can
> probably whip up a vanilla kernel if the maintainers in this area
> prefer that.
>=20
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D167835

Can you please give some more feedback like=20

1) how does your kernel .config look like?
2) which modules are loaded
3) how does your ruleset look like?
4) most importantly, have you enabled CONFIG_IP_NF_CONNTRACK_EVENTS ?
   if yes, please disable, it's broken, a fix has been submitted, but I
   don't know if it has propagated to Linus yet (netdev Message-ID:
   <20050922143515.GD8917@rama.de.gnumonks.org>)


please also try=20

a) only loading iptable_filter (and ip_tables), but no other modules
a) only loading ip_conntrack but no other netfilter modules (no nat, no ipt=
ables)
b) only loading ip_conntrack and iptable_nat (but no rules)

this kind of debugging helps to locate where it is.  netfilter has grown
big ;)

Also, I have that Ping time problem on my x86_64 debian unstable (smp).
But only in 1 out of ten cases on average (when starting ping, ctrl+c,
pin, ctrl+c, ...).  I've always assumed it's some 64bit problem in
"ping" itself.

--=20
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

--OOApBOWN8PWHaZPG
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDNqmQXaXGVTD0i/8RAs8gAJ9WFtsxjpA7z1b9H6kDVrFEhMim+gCfbH7s
5lCq4RbuPdJzClT4RWBL3pw=
=vbY3
-----END PGP SIGNATURE-----

--OOApBOWN8PWHaZPG--
