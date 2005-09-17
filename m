From: Harald Welte <laforge@netfilter.org>
Subject: Re: [HELP] netfilter Kconfig dependency nightmare
Date: Sat, 17 Sep 2005 13:29:49 +0200
Message-ID: <20050917112949.GZ8413@sunbeam.de.gnumonks.org>
References: <20050916021451.3012196c.akpm@osdl.org>
	<20050916191959.GN8413@sunbeam.de.gnumonks.org>
	<39e6f6c705091617514457eded@mail.gmail.com>
	<20050917012315.GA29841@mandriva.com>
	<20050917080714.GV8413@sunbeam.de.gnumonks.org>
	<Pine.LNX.4.61.0509171306290.3743@scrub.home>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/0ZNML3L+nUf91nU"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	Linux Kernel Mailinglist <linux-kernel@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Roman Zippel <zippel@linux-m68k.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0509171306290.3743@scrub.home>
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


--/0ZNML3L+nUf91nU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Sep 17, 2005 at 01:08:58PM +0200, Roman Zippel wrote:
> Hi,

Hi Roman, thanks for your reply.

> On Sat, 17 Sep 2005, Harald Welte wrote:
>=20
> > ip_conntrack =3D=3D CONFIG_IP_NF_CONNTRACK
> > nfnetlink =3D=3D CONFIG_NETFILTER_NETLINK
> > ip_conntrack_netlink =3D=3D CONFIG_IP_NF_CONNTRACK_NETLINK
> >=20
> > If nfnetlink =3D=3D N, ip_conntrack can be N or M or Y
> > If nfnetlink =3D=3D M, ip_conntrack can be N or M
> > If nfnetlink =3D=3D Y, ip_conntrack can be Y or M
>=20
> Where is the requirement for the last one coming from?

sorry.  The last one should be N,M or Y.

The fundamental underlying problem is:

If CONFIG_IP_NF_CONNTRACK_NETLINK is selected (M or Y), then
CONFIG_IP_NF_CONNTRACK conditionally adds some code that references
symbols from nfnetlink.ko (CONFIG_NETFILTER_NETLINK)

So basically, enabling CONFIG_IP_NF_CONNTRACK_NETLINK creates a dependency
=66rom CONFIG_IP_NF_CONNTRACK to CONFIG_NETFILTER_NETLINK.  AFAIK, the synt=
ax
doesn't allow somthing like=20

tristate IP_NF_CONNTRACK
	depends on NETFILTER_NETLINK if IP_NF_CONNTRACK_NETLINK!=3Dn

So, if ip_conntrack_netlink =3D=3D M (or Y), and ip_conntrack =3D=3D Y, then
nfnetlink has to be set to Y (but cannot be a module).

Is there something that resembles=20

And no, I do not see any chance to solve the problem in the code,
without either
1) adding yet another new module that only contains some 1kB of code and
   that requires additional EXPORT_SYMBOLS() on private data from
   ip_conntrack
or
2) adding dead code to ip_conntrack.ko that isn't used in many common
   configurations

:(

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--/0ZNML3L+nUf91nU
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDK/4tXaXGVTD0i/8RAlKwAJ0aIi1YXZxxiEmFNYT0A+iVoTuu7QCgsyKJ
VgF9YhdXvqk+WH2ydr8qNIo=
=x6fY
-----END PGP SIGNATURE-----

--/0ZNML3L+nUf91nU--
