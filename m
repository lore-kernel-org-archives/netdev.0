From: Harald Welte <laforge@gnumonks.org>
Subject: Re: packet re-ordering on SMP machines.
Date: Sun, 15 Sep 2002 10:42:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020915104201.D3810@sunbeam.de.gnumonks.org>
References: <20020827142004.C4358@wotan.suse.de> <200208271306.RAA19164@sex.inr.ac.ru> <20020827151317.A3389@wotan.suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="QgTrJPeCZfhZbFCN"
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20020827151317.A3389@wotan.suse.de>; from ak@suse.de on Tue, Aug 27, 2002 at 03:13:17PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--QgTrJPeCZfhZbFCN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 27, 2002 at 03:13:17PM +0200, Andi Kleen wrote:
>=20
> On Tue, Aug 27, 2002 at 05:06:30PM +0400, A.N.Kuznetsov wrote:
> > Hello!
> >=20
> > > Of course. The only problem is that the clock can be non mononotonous=
=20
> > > sometimes and not be in sync with gettimeofday, but at least the kern=
el=20
> > > users of packet timestamps do not care.
> >=20
> > What kernel users? Where did you find them? :-)
>=20
> Hmm, I thought TCP used it, but it seems to use jiffies directly.
>=20
> Ok, no kernel users then. Not sure about sunrpc and out of tree stuff
> like SCTP.

The iptables ULOG target passes the skb receive timestamp to userspace, whe=
re
it is (depending on local ulogd configuration) written in logging/accounting
databases. (ULOG is in the kernel tree).=20=20

The issue is that ULOG is batching multiple packets (or parts of packets) i=
nto
one netlink message sent to userspace.  If userspace would make a timestamp,
it would be very inaccurate.

There is at least one more iptables extension (out of the kernel tree) using
it - but I wouldn't consider this as important.

> -Andi

--=20
Live long and prosper
- Harald Welte / laforge@gnumonks.org               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
GCS/E/IT d- s-: a-- C+++ UL++++$ P+++ L++++$ E--- W- N++ o? K- w--- O- M+=
=20
V-- PS++ PE-- Y++ PGP++ t+ 5-- !X !R tv-- b+++ !DI !D G+ e* h--- r++ y+(*)

--QgTrJPeCZfhZbFCN
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE9hEfZXaXGVTD0i/8RAsZQAKCp+oE1Ud5bJlFstlyTGQBL/O4gVgCfTCTU
iWjRjN0Vuhzf4CdqoZFbv2A=
=e38Z
-----END PGP SIGNATURE-----

--QgTrJPeCZfhZbFCN--
