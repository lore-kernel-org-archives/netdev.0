From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC] Moving files around in drivers/net
Date: Sun, 19 Jun 2011 18:42:13 -0700
Message-ID: <1308534134.22851.13.camel@jtkirshe-mobl>
References: <1306956602.32125.28.camel@Joe-Laptop>
	 <1306957998.3076.18.camel@jtkirshe-MOBL1>
	 <1306958478.32125.32.camel@Joe-Laptop>
	 <BANLkTi=BAqKzZeLF2_uCYnr7PD3StGFgAg@mail.gmail.com>
	 <1308186619.12377.23.camel@Joe-Laptop>
	 <BANLkTinb0U+=rbK65Xs+E+GBwqvVSV_a9A@mail.gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-8vmx9z4mxOi7zHjaXt09"
Cc: Joe Perches <joe@perches.com>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Jan Engelhardt <jengelh@medozas.de>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38924 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991Ab1FTBmP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jun 2011 21:42:15 -0400
In-Reply-To: <BANLkTinb0U+=rbK65Xs+E+GBwqvVSV_a9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-8vmx9z4mxOi7zHjaXt09
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-06-15 at 20:34 -0700, Po-Yu Chuang wrote:
> Dear Joe,
>=20
> On Thu, Jun 16, 2011 at 9:10 AM, Joe Perches <joe@perches.com> wrote:
> > On Wed, 2011-06-15 at 11:38 -0700, Jeff Kirsher wrote:
> >> On Wed, Jun 1, 2011 at 13:01, Joe Perches <joe@perches.com> wrote:
> >> > On Wed, 2011-06-01 at 12:53 -0700, Jeff Kirsher wrote:
> >> >> On Wed, 2011-06-01 at 12:30 -0700, Joe Perches wrote:
> >> >> > Does anyone still think moving files around in drivers/net
> >> >> > would be sensible and a suitable candidate for inclusion
> >> >> > in 3.1?
> >> >> > Here's what Jeffrey proposed:
> >> >> > http://vger.kernel.org/netconf2010_slides/netconf-jtk.pdf
> >> >> > Here's what I proposed before that.
> >> >> > http://www.spinics.net/lists/netdev/msg149717.html
> >> >> I am over 90% done with the work and have been trying to finish up =
the
> >> >> patches so that I could get them out as an RFC here in the next wee=
k.
> >> > Excellent, thanks.
> >> I thought for sure I would have finished what I have left by last
> >> weekend, but I keep getting interrupted.  (Blame it on the NHL stanley
> >> cup playoffs) :)
> >> I have created a git tree on kernel.org with all the work that I have
> >> completed so far (see below).  This first stage of the move is only
> >> taking care of the drivers.  The next stage will move the networking
> >> core drivers (bridging, bonding, vlan, etc.) into drivers/net/sw.
> >> git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-organize
> >> I will send out all the patches as an RFC by the end of the week (for =
sure)
> >
> > I've put the body of the git log below my comments
> > to make it easier to discuss.
> >
> > Comments:
> >
> > pktgen in hamachi/yellowfin should be pkteng
> >
> > I think it might be better if:
> >
> > Things were more spelled out:
> >        pkteng should be packetengines
> > And things maybe not spelled out
> >        ixp2000 might just be ixp (what not intel?:)
> >
> > And maybe drivers/net/ethernet/ should be as
> > unpopulated as possible.  Maybe create a misc
> > directory and throw old unclassifiable junk there.
> >
> > Lance should be its own directory like 8390.
> > I think a2065 and ariadne are lance drivers.
> >
> > Some manufacturer directories are directly populated
> > with multiple drivers, some have subdirectories.
> > Should one style be consistently used?
> >
> > pch_gbe should probably be oki.
> >
> > Isn't syskonnect now marvell?
> >
> > stmmac may not be a good name.  Maybe stmicro.
> >
> > enic may not be a good name.  Maybe cisco.
> >
> > mlx4 may be mellanox
> >
> > sfc may be solarflare
> >
> > bna may be brocade
> >
> > cheers, Joe
> >
>=20
> [snip...]
>=20
> > commit 5fe875b9e93af6b5a099b37471bebb541f1ba0c6
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Thu May 19 22:06:03 2011 -0700
> >
> >    arm: Move the ARM/ACORN drivers
> >
> >    Move the ARM/ACORN drivers into drivers/net/ethernet/arm/ and make t=
he
> >    necessary Kconfig and Makefile changes.
> >    There were 4 drivers (TI Davinci & ftmac100) not in the
> >    drivers/net/arm/ which should have been since they are only supporte=
d
> >    under ARM, so they were added to the new directory structure.
> >
> >    NOTE: There are no "maintainers" for the TI Davinci drivers, so I am
> >    CC'ing the last 3 major contributors from TI.
> >
> >    CC: Sriram <srk@ti.com>
> >    CC: Vinay Hegde <vinay.hegde@ti.com>
> >    CC: Cyril Chemparathy <cyril@ti.com>
> >    CC: Russell King <linux@arm.linux.org.uk>
> >    CC: Wan ZongShun <mcuos.com@gmail.com>
> >    CC: Lennert Buytenhek <kernel@wantstofly.org>
> >    CC: Krzysztof Halasa <khc@pm.waw.pl>
> >    CC: Po-Yu Chuang <ratbert@faraday-tech.com>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  MAINTAINERS                                    |   10 +-
> >  drivers/net/Kconfig                            |   51 ---------
> >  drivers/net/Makefile                           |    7 --
> >  drivers/net/arm/Kconfig                        |   74 -------------
> >  drivers/net/ethernet/Kconfig                   |    1 +
> >  drivers/net/ethernet/Makefile                  |    1 +
> >  drivers/net/ethernet/arm/Kconfig               |  138 ++++++++++++++++=
++++++++
> >  drivers/net/{ =3D> ethernet}/arm/Makefile        |    6 +-
> >  drivers/net/{ =3D> ethernet}/arm/am79c961a.c     |    0
> >  drivers/net/{ =3D> ethernet}/arm/am79c961a.h     |    0
> >  drivers/net/{ =3D> ethernet}/arm/at91_ether.c    |    0
> >  drivers/net/{ =3D> ethernet}/arm/at91_ether.h    |    0
> >  drivers/net/{ =3D> ethernet/arm}/davinci_cpdma.c |    0
> >  drivers/net/{ =3D> ethernet/arm}/davinci_cpdma.h |    0
> >  drivers/net/{ =3D> ethernet/arm}/davinci_emac.c  |    0
> >  drivers/net/{ =3D> ethernet/arm}/davinci_mdio.c  |    0
> >  drivers/net/{ =3D> ethernet}/arm/ep93xx_eth.c    |    0
> >  drivers/net/{ =3D> ethernet}/arm/ether1.c        |    0
> >  drivers/net/{ =3D> ethernet}/arm/ether1.h        |    0
> >  drivers/net/{ =3D> ethernet}/arm/ether3.c        |    0
> >  drivers/net/{ =3D> ethernet}/arm/ether3.h        |    0
> >  drivers/net/{ =3D> ethernet}/arm/etherh.c        |    0
> >  drivers/net/{ =3D> ethernet/arm}/ftgmac100.c     |    0
> >  drivers/net/{ =3D> ethernet/arm}/ftgmac100.h     |    0
> >  drivers/net/{ =3D> ethernet/arm}/ftmac100.c      |    0
> >  drivers/net/{ =3D> ethernet/arm}/ftmac100.h      |    0
> >  drivers/net/{ =3D> ethernet}/arm/ixp4xx_eth.c    |    0
> >  drivers/net/{ =3D> ethernet}/arm/ks8695net.c     |    0
> >  drivers/net/{ =3D> ethernet}/arm/ks8695net.h     |    0
> >  drivers/net/{ =3D> ethernet}/arm/w90p910_ether.c |    0
> >  30 files changed, 150 insertions(+), 138 deletions(-)
> >
>=20
> [snip...]
>=20
> Faraday ftmac100 and ftgmac100 are used by not only ARM SoCs.
> There are SoCs of NDS32 architecture use these controllers, but
> NDS32 architecture is not in Linux mainline (yet).
> If these drivers were moved to arm directory, they maybe need to be
> moved out of it someday.
>=20
> So, how about:
> driver/net{ =3D> ethernet/faraday}/ftmac100.c
> driver/net{ =3D> ethernet/faraday}/ftgmac100.c
>=20
> Best regards,
> Po-Yu Chuang

That sounds fine, I will make the change.

--=-8vmx9z4mxOi7zHjaXt09
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJN/qV1AAoJECTsCADr/EWUxYEH/AqZoO5ZI2BKXUun2Fsf/nh7
25ZkQZPmXM4M1BRIyG0Y78+zVsg4klDtaODIYtYpMxj1X4/Yn3s4r6jJt0DlCoKD
admF4Phv3ApRaeiBNa1qscyWxwre0Zn896wzb3X8rU5xgQ44Ss5kRO3SMFzIGvWu
ZFxe1XWn/IVrygDeDi13t9+iJzPhJHV1hBuJmnOOXQI5a5wpBEyZpihWQxxfM3ue
NbjKm9GaPSWihr+flPqexx7PHKmZSw/l6qVhebDmvOfG2cCpp+HACFNAZhk0qqzH
Osy9a75sKIZtpUf5KvHuEQm/LnmO2bZ3DOwcEP7OZAvd7Cm74JwzBiiY/p/kH3Y=
=QCYl
-----END PGP SIGNATURE-----

--=-8vmx9z4mxOi7zHjaXt09--

