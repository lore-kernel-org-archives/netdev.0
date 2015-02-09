From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [E1000-devel] [PATCH 1/3] ixgbe, ixgbevf: Add new mbox API to
 enable MC promiscuous mode
Date: Mon, 09 Feb 2015 00:20:46 -0800
Message-ID: <1423470046.27854.7.camel@jtkirshe-mobl>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E1908D@BPXM14GP.gisp.nec.co.jp>
	 <1423054641.2589.59.camel@jtkirshe-mobl>
	  <7F861DC0615E0C47A872E6F3C5FCDDBD05E26E45@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-jfimw7ZWYwk+l2Yg+stM"
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	=?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@ACULAB.COM>,
	Hayato Momma <h-momma@ce.jp.nec.com>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E26E45@BPXM14GP.gisp.nec.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-jfimw7ZWYwk+l2Yg+stM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-02-09 at 06:59 +0000, Hiroshi Shimamoto wrote:
> > > Subject: Re: [E1000-devel] [PATCH 1/3] ixgbe, ixgbevf: Add new mbox A=
PI to enable MC promiscuous mode
> > >
> > > On Fri, 2015-01-30 at 11:37 +0000, Hiroshi Shimamoto wrote:
> > > > From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> > > >
> > > > The limitation of the number of multicast address for VF is not eno=
ugh
> > > > for the large scale server with SR-IOV feature.
> > > > IPv6 requires the multicast MAC address for each IP address to hand=
le
> > > > the Neighbor Solicitation message.
> > > > We couldn't assign over 30 IPv6 addresses to a single VF interface.
> > > >
> > > > The easy way to solve this is enabling multicast promiscuous mode.
> > > > It is good to have a functionality to enable multicast promiscuous
> > > > mode
> > > > for each VF from VF driver.
> > > >
> > > > This patch introduces the new mbox API, IXGBE_VF_SET_MC_PROMISC, to
> > > > enable/disable multicast promiscuous mode in VF. If multicast
> > > > promiscuous
> > > > mode is enabled the VF can receive all multicast packets.
> > > >
> > > > With this patch, the ixgbevf driver automatically enable multicast
> > > > promiscuous mode when the number of multicast addresses is over tha=
n
> > > > 30
> > > > if possible.
> > > >
> > > > This also bump the API version up to 1.2 to check whether the API,
> > > > IXGBE_VF_SET_MC_PROMISC is available.
> > > >
> > > > Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> > > > Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
> > > > CC: Choi, Sy Jong <sy.jong.choi@intel.com>
> > > > ---
> > > >  drivers/net/ethernet/intel/ixgbe/ixgbe.h          |  1 +
> > > >  drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |  4 +
> > > >  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    | 89
> > > > ++++++++++++++++++++++-
> > > >  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 13 +++-
> > > >  drivers/net/ethernet/intel/ixgbevf/mbx.h          |  4 +
> > > >  drivers/net/ethernet/intel/ixgbevf/vf.c           | 29 +++++++-
> > > >  drivers/net/ethernet/intel/ixgbevf/vf.h           |  1 +
> > > >  7 files changed, 137 insertions(+), 4 deletions(-)
> > >
> > > Hiroshi, I tried to apply your patches to my queue but they do not ap=
ply
> > > cleanly and they are in a DOS file format, not UNIX.  I also noted
> > > several checkpatch.pl issues with your patches, so please fix those u=
p
> > > as well.
> >=20
> > I'm sorry to bother you.
> > Will fix.
> >=20
> > >
> > > Can you please fix up your patches based on my tree:
> > > git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/queue.git
> >=20
> > Yes. I haven't noticed your tree.
> > Will resend patches against it.
> >=20
>=20
> I encountered an issue with your tree, the commit id is below.
>=20
> $ git log | head
> commit e6f1649780f8f5a87299bf6af04453f93d1e3d5e
> Author: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> Date:   Fri Jan 23 20:43:14 2015 -0800
>=20
>     ethernet: fm10k: Actually drop 4 bits
>=20
>     The comment explains the intention, but vid has type u16. Before the
>     inner shift, it is promoted to int, which has plenty of space for all
>     vid's bits, so nothing is dropped. Use a simple mask instead.
>=20
>=20
> I use the kernel from your tree in both host and guest.
>=20
> Assign an IPv6 for VF in guest.
> # ip -6 addr add 2001:db8::18:1/64 dev ens0
>=20
> Send ping packet from other server to the VM.
> # ping6  2001:db8::18:1 -I eth0
>=20
> The following message was shown.
> ixgbevf 0000:00:08.0: partial checksum but l4 proto=3D3a!
>=20
> If I did the same operation in the host, I saw the same error message in =
host too.
> ixgbe 0000:2d:00.0: partial checksum but l4 proto=3D3a!
>=20
> Do you have any idea about that?

Ah, sorry about that, try this tree again:
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/queue.git

That patch was dropped for favor of a patch that Matthew Vick put
together (and recently got pushed upstream).  So my queue no longer has
that patch in the queue, since it got dropped.

--=-jfimw7ZWYwk+l2Yg+stM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU2G3eAAoJEOVv75VaS+3OLQUP/2xZ8T5jGOHbBK+vwHbBYkOQ
NAKX2zPIsiJnzOQ02i3RqcgKsSGhsrDjVuEVSUmSWj5JeIsxwCpm4X85JFcTtbLR
rHdkzUY+s3+O3mAtmCGLuCoIX+MDCAzGRbpuSJz6RzUvNE6HbM140cBEkTQX76UH
WcjQAQFP4QYOW0M6dnimkBn1h0wpLCwU1PloNsP40Oj8R08Yw481sxZ1CUhtX7ca
YYgWZJSmcwpm7+6+iEBtf/QvKApS6NoYOW8FsNX35fr767AyncDj7a2Fqk/7AbrO
JX9ipW2ReB9hrl56a3GN/a0+apANNUtIGohvDFVlzblfS7TYgjW3R+5leDIcb9lB
+kS5Vfx0U073rs5rpyi2GJduinImOgkk1wuBTdBK6owaLz9Z8VR0nzaK703/C85d
QkxfHBTUMLhVQgEs/K/VgQDQaD/wfHMJFL9+O/s46YA6VInp+XAmGheiJGrPqjuV
mVszwsOAAmtMhY14eKvThcDL9pwojSiF3LAtNB89Ya2Fd1BCi6FOsUPnnNVC4tRs
x5ZRsghsgeebBwAoMAH0Xqvbb1/YSeSqow3Yi/TSyojrUrNMU1ZyDESrcn9Ol+dD
j0TQSSMj4VcuRhEe834uv2CwgVUOYj+TkdIep7+E6f5QbUgU08xnpRcHkeqEU0sB
/xFnVMMgb4qvkMiQ1y0i
=Y+xH
-----END PGP SIGNATURE-----

--=-jfimw7ZWYwk+l2Yg+stM--
