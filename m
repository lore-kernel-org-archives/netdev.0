From: Harald Welte <laforge@netfilter.org>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Fri, 12 Sep 2003 10:56:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030912085606.GC2350@obroa-skai.de.gnumonks.org>
References: <200309022116.41697.bdschuym@pandora.be> <20030903200426.59d0af4a.davem@redhat.com> <20030905153152.GA3623@obroa-skai.de.gnumonks.org> <1063330846.1028.11.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KDt/GgjP6HVcx58l"
Cc: "David S. Miller" <davem@redhat.com>,
   Bart De Schuymer <bdschuym@pandora.be>, acme@conectiva.com.br,
   netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1063330846.1028.11.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--KDt/GgjP6HVcx58l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 11, 2003 at 09:40:46PM -0400, jamal wrote:
> Harald,
>=20
> Could you not resolve all the ifindices of the said ppp+ interfaces
> at rule installation time and do an integer compare instead?

No, this is a different semantic.  Ifindexes change when an interface
goes down and comes up again (let's say you have a PPTP tunnel server
which terminates a couple of ppp* interfaces).

What could be done, is register with the netdev notifiers and then at
every ifup/ifdown event change the ifindex[es] in all rules that use=20
this style of match.

This is what was done in the 2.2 ipchains code, if I am not mistaken.
However, Rusty went for the string-compare solution while implementing
iptables. =20

Imagine somebody with lots of ppp interfaces (let's say 40)... and we
would need to resolve all 40 into ifindexes, put them into an array...
how big would you like to make the array?  how many interfaces do people
have? how much space do you want to waste (dynamically reallocating this
space while the ruleset is already loaded is not possible).

And then you have 1000 rules, each of it using a ppp* style match. than
at every ifdown/ifup you iterate over 1000 rules, checking if you need
to update one of the 40 ifindexes?  quite slow...

> cheers,
> jamal
--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--KDt/GgjP6HVcx58l
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/YYomXaXGVTD0i/8RAuezAKCuInUQScakwr9dcR6Nrfgu0ewlIwCgg9sN
ueVML/xfEh06XNPclYhyROI=
=fcak
-----END PGP SIGNATURE-----

--KDt/GgjP6HVcx58l--
