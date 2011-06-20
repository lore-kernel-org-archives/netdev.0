From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC] Moving files around in drivers/net
Date: Sun, 19 Jun 2011 19:25:29 -0700
Message-ID: <1308536729.22851.42.camel@jtkirshe-mobl>
References: <1306956602.32125.28.camel@Joe-Laptop>
	 <1306957998.3076.18.camel@jtkirshe-MOBL1>
	 <1306958478.32125.32.camel@Joe-Laptop>
	 <BANLkTi=BAqKzZeLF2_uCYnr7PD3StGFgAg@mail.gmail.com>
	 <1308186619.12377.23.camel@Joe-Laptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-7RG3bV9ETdMO0TSJjaAE"
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Jan Engelhardt <jengelh@medozas.de>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:44384 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750793Ab1FTCZa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jun 2011 22:25:30 -0400
In-Reply-To: <1308186619.12377.23.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7RG3bV9ETdMO0TSJjaAE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-06-15 at 18:10 -0700, Joe Perches wrote:
> On Wed, 2011-06-15 at 11:38 -0700, Jeff Kirsher wrote:
> > On Wed, Jun 1, 2011 at 13:01, Joe Perches <joe@perches.com> wrote:
> > > On Wed, 2011-06-01 at 12:53 -0700, Jeff Kirsher wrote:
> > >> On Wed, 2011-06-01 at 12:30 -0700, Joe Perches wrote:
> > >> > Does anyone still think moving files around in drivers/net
> > >> > would be sensible and a suitable candidate for inclusion
> > >> > in 3.1?
> > >> > Here's what Jeffrey proposed:
> > >> > http://vger.kernel.org/netconf2010_slides/netconf-jtk.pdf
> > >> > Here's what I proposed before that.
> > >> > http://www.spinics.net/lists/netdev/msg149717.html
> > >> I am over 90% done with the work and have been trying to finish up t=
he
> > >> patches so that I could get them out as an RFC here in the next week=
.
> > > Excellent, thanks.
> > I thought for sure I would have finished what I have left by last
> > weekend, but I keep getting interrupted.  (Blame it on the NHL stanley
> > cup playoffs) :)
> > I have created a git tree on kernel.org with all the work that I have
> > completed so far (see below).  This first stage of the move is only
> > taking care of the drivers.  The next stage will move the networking
> > core drivers (bridging, bonding, vlan, etc.) into drivers/net/sw.
> > git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-organize
> > I will send out all the patches as an RFC by the end of the week (for s=
ure)
>=20
> I've put the body of the git log below my comments
> to make it easier to discuss.
>=20
> Comments:
>=20
> pktgen in hamachi/yellowfin should be pkteng
>=20
> I think it might be better if:
>=20
> Things were more spelled out:
>         pkteng should be packetengines

That sounds fine.  I will make the change.

> And things maybe not spelled out
>         ixp2000 might just be ixp (what not intel?:)

While this is an Intel chip, the part was sold off and the driver is not
maintained by Intel.  That is reason why it does not reside in
the /driver/net/ethernet/intel/ directory.

I have not preference as to whether it resides in ixp2000 or ixp, so I
can make the change to ixp if you prefer.

>=20
> And maybe drivers/net/ethernet/ should be as
> unpopulated as possible.  Maybe create a misc
> directory and throw old unclassifiable junk there.

That is what I have been trying to do, and I do agree.

>=20
> Lance should be its own directory like 8390.
> I think a2065 and ariadne are lance drivers.
>=20
> Some manufacturer directories are directly populated
> with multiple drivers, some have subdirectories.
> Should one style be consistently used?

This is a grey area.  I think it makes more sense to group drivers
either by company, maintainer, bus or commonly used header.  It has been
expressed by others in the community and while placing drivers in
driver/net/ethernet/<company name> is nice way to organize, companies
get bought and sold and driver ownership moves from one company to
another.  To constantly rename directories based on the ownership may
cause un-necessary flux in the directory structure.  I tried to tried to
avoid using company names unless I was confident about it.

Some of the suggestions you listed below seem fine, especially since
several of these companies have been around for some time and actively
maintain their driver(s).

>=20
> pch_gbe should probably be oki.
>=20
> Isn't syskonnect now marvell?
>=20
> stmmac may not be a good name.  Maybe stmicro.
>=20
> enic may not be a good name.  Maybe cisco.
>=20
> mlx4 may be mellanox
>=20
> sfc may be solarflare
>=20
> bna may be brocade
>=20
> cheers, Joe
>=20
> $ git log --stat -M b7c7deeb4c77538577f0b6a724f10ce8693eb648..
> commit 743b1f134daef72805cb10e74d82dcbb95cd2568
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Tue Jun 14 14:02:57 2011 -0700
>=20
>     hamachi/yellowfin: Move the packet engine drivers
>=20
>     Move the packet engine drivers to drivers/net/ethernet/pktgen/ and
>     the necessary Kconfig and Makefile changes.
>=20
>     CC: Donald Becker <becker@scyld.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  drivers/net/Kconfig                           |   26 ---------------
>  drivers/net/Makefile                          |    2 -
>  drivers/net/ethernet/Kconfig                  |    1 +
>  drivers/net/ethernet/Makefile                 |    1 +
>  drivers/net/ethernet/pkteng/Kconfig           |   42 +++++++++++++++++++=
++++++
>  drivers/net/ethernet/pkteng/Makefile          |    6 +++
>  drivers/net/{ =3D> ethernet/pkteng}/hamachi.c   |    0
>  drivers/net/{ =3D> ethernet/pkteng}/yellowfin.c |    0
>  8 files changed, 50 insertions(+), 28 deletions(-)
>=20
> commit a7ce0b86340574f90bd24c460c3495ae3e06f5fb
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Tue Jun 14 13:35:31 2011 -0700
>=20
>     ixp2000: Move the Radisys driver
>=20
>     Move the Radisys driver into drivers/net/ethernet/ixp2000/ and
>     make the necessary Kconfig and Makefile changes
>=20
>     CC: Lennert Buytenhek <kernel@wantstofly.org>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                        |    2 +-
>  drivers/net/Kconfig                                |    2 --
>  drivers/net/Makefile                               |    1 -
>  drivers/net/ethernet/Kconfig                       |    1 +
>  drivers/net/ethernet/Makefile                      |    1 +
>  drivers/net/{ =3D> ethernet}/ixp2000/Kconfig         |    0
>  drivers/net/{ =3D> ethernet}/ixp2000/Makefile        |    0
>  drivers/net/{ =3D> ethernet}/ixp2000/caleb.c         |    0
>  drivers/net/{ =3D> ethernet}/ixp2000/caleb.h         |    0
>  drivers/net/{ =3D> ethernet}/ixp2000/enp2611.c       |    0
>  drivers/net/{ =3D> ethernet}/ixp2000/ixp2400-msf.c   |    0
>  drivers/net/{ =3D> ethernet}/ixp2000/ixp2400-msf.h   |    0
>  drivers/net/{ =3D> ethernet}/ixp2000/ixp2400_rx.uc   |    0
>  .../net/{ =3D> ethernet}/ixp2000/ixp2400_rx.ucode    |    0
>  drivers/net/{ =3D> ethernet}/ixp2000/ixp2400_tx.uc   |    0
>  .../net/{ =3D> ethernet}/ixp2000/ixp2400_tx.ucode    |    0
>  drivers/net/{ =3D> ethernet}/ixp2000/ixpdev.c        |    0
>  drivers/net/{ =3D> ethernet}/ixp2000/ixpdev.h        |    0
>  drivers/net/{ =3D> ethernet}/ixp2000/ixpdev_priv.h   |    0
>  drivers/net/{ =3D> ethernet}/ixp2000/pm3386.c        |    0
>  drivers/net/{ =3D> ethernet}/ixp2000/pm3386.h        |    0
>  21 files changed, 3 insertions(+), 4 deletions(-)
>=20
> commit 73091715bc0690f82ef9489f3589ad9b2d747cc0
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Tue Jun 14 12:56:50 2011 -0700
>=20
>     tlan/cpmac: Move the TI drivers
>=20
>     Move the TI drivers to drivers/net/ethernet/ti/ and make the
>     necessary Kconfig and Makefile changes.
>=20
>     CC: Samuel Chessman <chessman@tux.org>
>     CC: <torben.mathiasen@compaq.com>
>     CC: Eugene Konev <ejka@imfi.kspu.ru>
>     CC: Florian Fainelli <florian@openwrt.org>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                           |    4 +-
>  drivers/net/Kconfig                   |   25 --------------------
>  drivers/net/Makefile                  |    2 -
>  drivers/net/ethernet/Kconfig          |    1 +
>  drivers/net/ethernet/Makefile         |    1 +
>  drivers/net/ethernet/ti/Kconfig       |   41 +++++++++++++++++++++++++++=
++++++
>  drivers/net/ethernet/ti/Makefile      |    6 +++++
>  drivers/net/{ =3D> ethernet/ti}/cpmac.c |    0
>  drivers/net/{ =3D> ethernet/ti}/tlan.c  |    0
>  drivers/net/{ =3D> ethernet/ti}/tlan.h  |    0
>  10 files changed, 51 insertions(+), 29 deletions(-)
>=20
> commit 035a452c66dbc0aa7873a12cfe057c74eaf89111
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Mon Jun 13 10:51:34 2011 -0700
>=20
>     s6gmac/tsi108_eth: Move the s6gmac/tsi108_eth drivers
>=20
>     Move the s6gmac/tsi108_eth drivers to drivers/net/ethernet/ and
>     make the necessary Kconfig and Makefile changes.
>=20
>     CC: Oskar Schirmer <os@emlix.com>
>     CC: Kong Lai <kong.lai@tundra.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  drivers/net/Kconfig                     |   19 -------------------
>  drivers/net/Makefile                    |    2 --
>  drivers/net/ethernet/Kconfig            |   21 +++++++++++++++++++++
>  drivers/net/ethernet/Makefile           |    2 ++
>  drivers/net/{ =3D> ethernet}/s6gmac.c     |    0
>  drivers/net/{ =3D> ethernet}/tsi108_eth.c |    0
>  drivers/net/{ =3D> ethernet}/tsi108_eth.h |    0
>  7 files changed, 23 insertions(+), 21 deletions(-)
>=20
> commit 4f9d3b9af95ced49b9ad9d5fb222f5216bf0adbb
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Mon Jun 13 10:03:01 2011 -0700
>=20
>     a2065/ariadne: Move the a2065/ariadne drivers
>=20
>     Move the a2065/ariadne drivers to drivers/net/ethernet/ and make
>     the necessary Kconfig and Makefile changes.
>=20
>     CC: Geert Uytterhoeven <geert@linux-m68k.org>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  drivers/net/Kconfig                  |   21 ---------------------
>  drivers/net/Makefile                 |    2 --
>  drivers/net/ethernet/Kconfig         |   23 +++++++++++++++++++++++
>  drivers/net/ethernet/Makefile        |    2 ++
>  drivers/net/{ =3D> ethernet}/a2065.c   |    0
>  drivers/net/{ =3D> ethernet}/a2065.h   |    0
>  drivers/net/{ =3D> ethernet}/ariadne.c |    0
>  drivers/net/{ =3D> ethernet}/ariadne.h |    0
>  8 files changed, 25 insertions(+), 23 deletions(-)
>=20
> commit aead66521a701f08e3ae91aec7c9c8863a07a511
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Mon Jun 13 09:43:17 2011 -0700
>=20
>     82586.c/fec*: Move the Motorola drivers
>=20
>     Move the Motorola drivers into drivers/net/ethernet/motorola/ and
>     make the necessary Kconfig and Makefile changes
>=20
>     CC: Dan Malek <dmalek@jlc.net>
>     CC: Sylvain Munaut <tnt@246tNt.com>
>     CC: Richard Hirst <richard@sleepie.demon.co.uk>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  drivers/net/Kconfig                                |   49 --------------
>  drivers/net/Makefile                               |    7 --
>  drivers/net/ethernet/Kconfig                       |    1 +
>  drivers/net/ethernet/Makefile                      |    1 +
>  drivers/net/{ =3D> ethernet/motorola}/82596.c        |    0
>  drivers/net/ethernet/motorola/Kconfig              |   68 ++++++++++++++=
++++++
>  drivers/net/ethernet/motorola/Makefile             |   11 +++
>  drivers/net/{ =3D> ethernet/motorola}/fec.c          |    0
>  drivers/net/{ =3D> ethernet/motorola}/fec.h          |    0
>  drivers/net/{ =3D> ethernet/motorola}/fec_mpc52xx.c  |    0
>  drivers/net/{ =3D> ethernet/motorola}/fec_mpc52xx.h  |    0
>  .../net/{ =3D> ethernet/motorola}/fec_mpc52xx_phy.c  |    0
>  12 files changed, 81 insertions(+), 56 deletions(-)
>=20
> commit aebcb70982c66b54605fbd242f6ac035b2e205b3
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Mon Jun 13 08:43:49 2011 -0700
>=20
>     sis*: Move the Silicon Integrated Systems (SiS) drivers
>=20
>     Move the SiS drivers into drivers/net/ethernet/sis/ and make the
>     necessary Kconfig and Makefile changes
>=20
>     CC: Daniele Venzano <venza@brownhat.org>
>     CC: Francois Romieu <romieu@fr.zoreil.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                             |    4 +-
>  drivers/net/Kconfig                     |   30 --------------------
>  drivers/net/Makefile                    |    2 -
>  drivers/net/ethernet/Kconfig            |    1 +
>  drivers/net/ethernet/Makefile           |    1 +
>  drivers/net/ethernet/sis/Kconfig        |   46 +++++++++++++++++++++++++=
++++++
>  drivers/net/ethernet/sis/Makefile       |    6 ++++
>  drivers/net/{ =3D> ethernet/sis}/sis190.c |    0
>  drivers/net/{ =3D> ethernet/sis}/sis900.c |    0
>  drivers/net/{ =3D> ethernet/sis}/sis900.h |    0
>  10 files changed, 56 insertions(+), 34 deletions(-)
>=20
> commit 826bef22759e1f78b284c9dc53ea442d348dbc88
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Mon Jun 13 08:23:31 2011 -0700
>=20
>     spider_net: Move the spider_net (IBM) driver
>=20
>     Move the spider_net (IBM) driver into drivers/net/ethernet/ibm/ and
>     make the necessary Kconfig and Makefile changes
>=20
>     CC: Utz Bacher <utz.bacher@de.ibm.com>
>     CC: Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
>     CC: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                        |    2 +-
>  drivers/net/Kconfig                                |    8 --------
>  drivers/net/Makefile                               |    2 --
>  drivers/net/ethernet/ibm/Kconfig                   |   11 ++++++++++-
>  drivers/net/ethernet/ibm/Makefile                  |    2 ++
>  drivers/net/{ =3D> ethernet/ibm}/spider_net.c        |    0
>  drivers/net/{ =3D> ethernet/ibm}/spider_net.h        |    2 +-
>  .../net/{ =3D> ethernet/ibm}/spider_net_ethtool.c    |    0
>  8 files changed, 14 insertions(+), 13 deletions(-)
>=20
> commit 776fae874e79c3bf3b6fd81eceb23993fef76c01
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Mon Jun 13 07:56:34 2011 -0700
>=20
>     mv643xx/pxa168: Move the Marvell drivers
>=20
>     Move the Marvell drivers into driver/net/ethernet/marvell and make
>     the necessary Kconfig and Makefile changes.
>=20
>     CC: Sachin Sanap <ssanap@marvell.com>
>     CC: Zhangfei Gao <zgao6@marvell.com>
>     CC: Philip Rakity <prakity@marvell.com>
>     CC: Mark Brown <markb@marvell.com>
>     CC: Lennert Buytenhek <buytenh@marvell.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                      |    2 +-
>  drivers/net/Kconfig                              |   23 ------------
>  drivers/net/Makefile                             |    2 -
>  drivers/net/ethernet/Kconfig                     |    1 +
>  drivers/net/ethernet/Makefile                    |    1 +
>  drivers/net/ethernet/marvell/Kconfig             |   40 ++++++++++++++++=
++++++
>  drivers/net/ethernet/marvell/Makefile            |    6 +++
>  drivers/net/{ =3D> ethernet/marvell}/mv643xx_eth.c |    0
>  drivers/net/{ =3D> ethernet/marvell}/pxa168_eth.c  |    0
>  9 files changed, 49 insertions(+), 26 deletions(-)
>=20
> commit 4153aed9e3020693985219d471f8eb230a8eaefa
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Sat Jun 11 03:26:31 2011 -0700
>=20
>     ks8*/ksz8*: Move the Micrel drivers
>=20
>     Move the Micrel drivers into drivers/net/ethernet/micrel/ and
>     make the necessary Kconfig and Makefile changes.
>=20
>     CC: Ben Dooks <ben@simtec.co.uk>
>     CC: Tristram Ha <Tristram.Ha@micrel.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  drivers/net/Kconfig                            |   35 ----------------
>  drivers/net/Makefile                           |    4 --
>  drivers/net/ethernet/Kconfig                   |    1 +
>  drivers/net/ethernet/Makefile                  |    1 +
>  drivers/net/ethernet/micrel/Kconfig            |   51 ++++++++++++++++++=
++++++
>  drivers/net/ethernet/micrel/Makefile           |    8 ++++
>  drivers/net/{ =3D> ethernet/micrel}/ks8842.c     |    0
>  drivers/net/{ =3D> ethernet/micrel}/ks8851.c     |    0
>  drivers/net/{ =3D> ethernet/micrel}/ks8851.h     |    0
>  drivers/net/{ =3D> ethernet/micrel}/ks8851_mll.c |    0
>  drivers/net/{ =3D> ethernet/micrel}/ksz884x.c    |    0
>  11 files changed, 61 insertions(+), 39 deletions(-)
>=20
> commit 518f5abc833cb0c30b79161c071b7c93ed458c6d
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Sat Jun 11 02:29:36 2011 -0700
>=20
>     fsl_*/gianfar*/ucc_*: Move the Freescale drivers
>=20
>     Move the Freescale driver into drivers/net/ethernet/freescale/ and
>     make the necessary Kconfig and Makefile changes.
>=20
>     CC: Sandeep Gopalpet <sandeep.kumar@freescale.com>
>     CC: Andy Fleming <afleming@freescale.com>
>     CC: Shlomi Gridish <gridish@freescale.com>
>     CC: Li Yang <leoli@freescale.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                        |    2 +-
>  drivers/net/Kconfig                                |   33 -------------
>  drivers/net/Makefile                               |   14 ------
>  drivers/net/ethernet/Kconfig                       |    1 +
>  drivers/net/ethernet/Makefile                      |    1 +
>  drivers/net/ethernet/freescale/Kconfig             |   48 ++++++++++++++=
++++++
>  drivers/net/ethernet/freescale/Makefile            |   13 +++++
>  .../net/{ =3D> ethernet/freescale}/fs_enet/Kconfig   |    2 +-
>  .../net/{ =3D> ethernet/freescale}/fs_enet/Makefile  |    0
>  drivers/net/{ =3D> ethernet/freescale}/fs_enet/fec.h |    0
>  .../freescale}/fs_enet/fs_enet-main.c              |    0
>  .../net/{ =3D> ethernet/freescale}/fs_enet/fs_enet.h |    0
>  .../net/{ =3D> ethernet/freescale}/fs_enet/mac-fcc.c |    0
>  .../net/{ =3D> ethernet/freescale}/fs_enet/mac-fec.c |    0
>  .../net/{ =3D> ethernet/freescale}/fs_enet/mac-scc.c |    0
>  .../{ =3D> ethernet/freescale}/fs_enet/mii-bitbang.c |    0
>  .../net/{ =3D> ethernet/freescale}/fs_enet/mii-fec.c |    0
>  drivers/net/{ =3D> ethernet/freescale}/fsl_pq_mdio.c |    0
>  drivers/net/{ =3D> ethernet/freescale}/fsl_pq_mdio.h |    0
>  drivers/net/{ =3D> ethernet/freescale}/gianfar.c     |    0
>  drivers/net/{ =3D> ethernet/freescale}/gianfar.h     |    0
>  .../net/{ =3D> ethernet/freescale}/gianfar_ethtool.c |    0
>  drivers/net/{ =3D> ethernet/freescale}/gianfar_ptp.c |    0
>  .../net/{ =3D> ethernet/freescale}/gianfar_sysfs.c   |    0
>  drivers/net/{ =3D> ethernet/freescale}/ucc_geth.c    |    0
>  drivers/net/{ =3D> ethernet/freescale}/ucc_geth.h    |    0
>  .../{ =3D> ethernet/freescale}/ucc_geth_ethtool.c    |    0
>  27 files changed, 65 insertions(+), 49 deletions(-)
>=20
> commit dbf507c912fcc804a20d86d2194fc4a4298f39df
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Sat Jun 11 01:13:22 2011 -0700
>=20
>     eepro/eexpress/eth16i/ewrk3/lp486e/seeq8005/znet: Move the ISA driver=
s
>=20
>     Move the ISA drivers into drivers/net/ethernet/isa/ and make the
>     necessary Kconfig and Makefile changes.
>=20
>     CC: Philip Blundell <philb@gnu.org>
>     CC: Mika Kuoppala <miku@iki.fi>
>     CC: <bao.ha@srs.gov>
>     CC: <aris@cathedrallabs.org>
>     CC: David Davies <davies@maniac.ultranet.com>
>     CC: <aeb@cwi.nl>
>     CC: Hamish Coleman <hamish@zot.apana.org.au>
>     CC: Donald Becker <becker@scyld.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                               |    4 +-
>  drivers/net/Kconfig                       |   98 -----------------------=
-----
>  drivers/net/Makefile                      |   10 ---
>  drivers/net/ethernet/Kconfig              |    1 +
>  drivers/net/ethernet/Makefile             |    1 +
>  drivers/net/ethernet/isa/Kconfig          |  101 +++++++++++++++++++++++=
++++++
>  drivers/net/ethernet/isa/Makefile         |   11 +++
>  drivers/net/{ =3D> ethernet/isa}/eepro.c    |    0
>  drivers/net/{ =3D> ethernet/isa}/eexpress.c |    0
>  drivers/net/{ =3D> ethernet/isa}/eexpress.h |    0
>  drivers/net/{ =3D> ethernet/isa}/eth16i.c   |    0
>  drivers/net/{ =3D> ethernet/isa}/ewrk3.c    |    0
>  drivers/net/{ =3D> ethernet/isa}/ewrk3.h    |    0
>  drivers/net/{ =3D> ethernet/isa}/lp486e.c   |    0
>  drivers/net/{ =3D> ethernet/isa}/seeq8005.c |    0
>  drivers/net/{ =3D> ethernet/isa}/seeq8005.h |    0
>  drivers/net/{ =3D> ethernet/isa}/znet.c     |    0
>  17 files changed, 116 insertions(+), 110 deletions(-)
>=20
> commit b8a6199b8d692ae17932b8c8cc709898255a51ad
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Fri May 20 20:43:09 2011 -0700
>=20
>     via-*: Move the VIA drivers
>=20
>     Move the VIA drivers into drivers/net/ethernet/via/ and make the
>     necessary Kconfig and Makefile changes.
>=20
>     CC: Roger Luethi <rl@hellgate.ch>
>     CC: Francois Romieu <romieu@fr.zoreil.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                   |    4 +-
>  drivers/net/Kconfig                           |   36 -----------------
>  drivers/net/Makefile                          |    2 -
>  drivers/net/ethernet/Kconfig                  |    1 +
>  drivers/net/ethernet/Makefile                 |    1 +
>  drivers/net/ethernet/via/Kconfig              |   52 +++++++++++++++++++=
++++++
>  drivers/net/ethernet/via/Makefile             |    6 +++
>  drivers/net/{ =3D> ethernet/via}/via-rhine.c    |    0
>  drivers/net/{ =3D> ethernet/via}/via-velocity.c |    0
>  drivers/net/{ =3D> ethernet/via}/via-velocity.h |    0
>  10 files changed, 62 insertions(+), 40 deletions(-)
>=20
> commit 0cc82a49e423bc0b2ee19c49ad24376d1ffccdc5
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Fri May 20 20:18:55 2011 -0700
>=20
>     skge/sky2: Move the SysKonnect Ethernet drivers
>=20
>     Move the SysKonnect (Ethernet only) drivers into drivers/net/ethernet=
/syskonnect/
>     and make the necessary Kconfig and Makefile changes.
>=20
>     CC: Stephen Hemminger <shemminger@linux-foundation.org>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                  |    3 +-
>  drivers/net/Kconfig                          |   58 --------------------
>  drivers/net/Makefile                         |    2 -
>  drivers/net/ethernet/Kconfig                 |    1 +
>  drivers/net/ethernet/Makefile                |    1 +
>  drivers/net/ethernet/syskonnect/Kconfig      |   74 ++++++++++++++++++++=
++++++
>  drivers/net/ethernet/syskonnect/Makefile     |    6 ++
>  drivers/net/{ =3D> ethernet/syskonnect}/skge.c |    0
>  drivers/net/{ =3D> ethernet/syskonnect}/skge.h |    0
>  drivers/net/{ =3D> ethernet/syskonnect}/sky2.c |    0
>  drivers/net/{ =3D> ethernet/syskonnect}/sky2.h |    0
>  11 files changed, 83 insertions(+), 62 deletions(-)
>=20
> commit c9e8faa7214a8911a22281e6e688e0cc69bb54b8
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Fri May 20 19:48:55 2011 -0700
>=20
>     pch_gbe: Move the OKI driver
>=20
>     Move the OKI driver into driver/net/ethernet/pch_gbe/ and make the
>     necessary Kconfig and Makefile changes.
>=20
>     Note: there is no documented maintainer for this driver, so I CC'd
>     the last 2 major contributors.
>=20
>     CC: Tomoya <tomoya-linux@dsn.okisemi.com>
>     CC: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  drivers/net/Kconfig                                |   19 --------------=
-----
>  drivers/net/Makefile                               |    1 -
>  drivers/net/ethernet/Kconfig                       |    1 +
>  drivers/net/ethernet/Makefile                      |    1 +
>  drivers/net/ethernet/pch_gbe/Kconfig               |   20 ++++++++++++++=
++++++
>  drivers/net/{ =3D> ethernet}/pch_gbe/Makefile        |    0
>  drivers/net/{ =3D> ethernet}/pch_gbe/pch_gbe.h       |    0
>  drivers/net/{ =3D> ethernet}/pch_gbe/pch_gbe_api.c   |    0
>  drivers/net/{ =3D> ethernet}/pch_gbe/pch_gbe_api.h   |    0
>  .../net/{ =3D> ethernet}/pch_gbe/pch_gbe_ethtool.c   |    0
>  drivers/net/{ =3D> ethernet}/pch_gbe/pch_gbe_main.c  |    0
>  drivers/net/{ =3D> ethernet}/pch_gbe/pch_gbe_param.c |    0
>  drivers/net/{ =3D> ethernet}/pch_gbe/pch_gbe_phy.c   |    0
>  drivers/net/{ =3D> ethernet}/pch_gbe/pch_gbe_phy.h   |    0
>  14 files changed, 22 insertions(+), 20 deletions(-)
>=20
> commit 63e70fbc3837e36fbcc3e5b3d12eed74919e3beb
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Fri May 20 07:50:27 2011 -0700
>=20
>     ioc3-eth/meth/sgiseeq: Move the SGI drivers
>=20
>     Move the SGI drivers into drivers/net/ethernet/sgi/ and make the
>     necessary Kconfig and Makefile changes.
>=20
>     CC: Ralf Baechle <ralf@linux-mips.org>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                               |    2 +-
>  drivers/net/Kconfig                       |   21 ----------------
>  drivers/net/Makefile                      |    3 --
>  drivers/net/ethernet/Kconfig              |    1 +
>  drivers/net/ethernet/Makefile             |    1 +
>  drivers/net/ethernet/sgi/Kconfig          |   37 +++++++++++++++++++++++=
++++++
>  drivers/net/ethernet/sgi/Makefile         |    7 +++++
>  drivers/net/{ =3D> ethernet/sgi}/ioc3-eth.c |    0
>  drivers/net/{ =3D> ethernet/sgi}/meth.c     |    0
>  drivers/net/{ =3D> ethernet/sgi}/meth.h     |    0
>  drivers/net/{ =3D> ethernet/sgi}/sgiseeq.c  |    0
>  drivers/net/{ =3D> ethernet/sgi}/sgiseeq.h  |    0
>  12 files changed, 47 insertions(+), 25 deletions(-)
>=20
> commit 33bb1962fa6983fb17a7c95a5b44be697878783b
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Fri May 20 07:15:19 2011 -0700
>=20
>     tulip: Move the tulip drivers
>=20
>     Move the tulip driver into drivers/net/ethernet/tulip/ and make
>     the necessary Kconfig and Makefile changes.
>=20
>     CC: Tobias Ringstrom <tori@unhappy.mine.nu>
>     CC: Grant Grundler <grundler@parisc-linux.org>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                    |    4 ++--
>  drivers/net/Kconfig                            |    2 --
>  drivers/net/Makefile                           |    1 -
>  drivers/net/ethernet/Kconfig                   |    2 ++
>  drivers/net/ethernet/Makefile                  |    1 +
>  drivers/net/{ =3D> ethernet}/tulip/21142.c       |    0
>  drivers/net/{ =3D> ethernet}/tulip/Kconfig       |    0
>  drivers/net/{ =3D> ethernet}/tulip/Makefile      |    0
>  drivers/net/{ =3D> ethernet}/tulip/de2104x.c     |    0
>  drivers/net/{ =3D> ethernet}/tulip/de4x5.c       |    0
>  drivers/net/{ =3D> ethernet}/tulip/de4x5.h       |    0
>  drivers/net/{ =3D> ethernet}/tulip/dmfe.c        |    0
>  drivers/net/{ =3D> ethernet}/tulip/eeprom.c      |    0
>  drivers/net/{ =3D> ethernet}/tulip/interrupt.c   |    0
>  drivers/net/{ =3D> ethernet}/tulip/media.c       |    0
>  drivers/net/{ =3D> ethernet}/tulip/pnic.c        |    0
>  drivers/net/{ =3D> ethernet}/tulip/pnic2.c       |    0
>  drivers/net/{ =3D> ethernet}/tulip/timer.c       |    0
>  drivers/net/{ =3D> ethernet}/tulip/tulip.h       |    0
>  drivers/net/{ =3D> ethernet}/tulip/tulip_core.c  |    0
>  drivers/net/{ =3D> ethernet}/tulip/uli526x.c     |    0
>  drivers/net/{ =3D> ethernet}/tulip/winbond-840.c |    0
>  drivers/net/{ =3D> ethernet}/tulip/xircom_cb.c   |    0
>  23 files changed, 5 insertions(+), 5 deletions(-)
>=20
> commit 9091cea3242dcc16138cef784c4880a819b28c1e
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Fri May 20 06:55:16 2011 -0700
>=20
>     atl*: Move the Atheros drivers
>=20
>     Move the Atheros drivers into drivers/net/ethernet/atheros/ and
>     make the necessary Kconfig and Makefile changes.
>=20
>     CC: Jay Cliburn <jcliburn@gmail.com>
>     CC: Chris Snook <chris.snook@gmail.com>
>     CC: Jie Yang <jie.yang@atheros.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                        |    2 +-
>  drivers/net/Kconfig                                |   45 --------------
>  drivers/net/Makefile                               |    4 -
>  drivers/net/ethernet/Kconfig                       |    1 +
>  drivers/net/ethernet/Makefile                      |    1 +
>  drivers/net/ethernet/atheros/Kconfig               |   61 ++++++++++++++=
++++++
>  drivers/net/ethernet/atheros/Makefile              |    8 +++
>  drivers/net/{ =3D> ethernet/atheros}/atl1c/Makefile  |    0
>  drivers/net/{ =3D> ethernet/atheros}/atl1c/atl1c.h   |    0
>  .../{ =3D> ethernet/atheros}/atl1c/atl1c_ethtool.c   |    0
>  .../net/{ =3D> ethernet/atheros}/atl1c/atl1c_hw.c    |    0
>  .../net/{ =3D> ethernet/atheros}/atl1c/atl1c_hw.h    |    0
>  .../net/{ =3D> ethernet/atheros}/atl1c/atl1c_main.c  |    0
>  drivers/net/{ =3D> ethernet/atheros}/atl1e/Makefile  |    0
>  drivers/net/{ =3D> ethernet/atheros}/atl1e/atl1e.h   |    0
>  .../{ =3D> ethernet/atheros}/atl1e/atl1e_ethtool.c   |    0
>  .../net/{ =3D> ethernet/atheros}/atl1e/atl1e_hw.c    |    0
>  .../net/{ =3D> ethernet/atheros}/atl1e/atl1e_hw.h    |    0
>  .../net/{ =3D> ethernet/atheros}/atl1e/atl1e_main.c  |    0
>  .../net/{ =3D> ethernet/atheros}/atl1e/atl1e_param.c |    0
>  drivers/net/{ =3D> ethernet/atheros}/atlx/Makefile   |    0
>  drivers/net/{ =3D> ethernet/atheros}/atlx/atl1.c     |    0
>  drivers/net/{ =3D> ethernet/atheros}/atlx/atl1.h     |    0
>  drivers/net/{ =3D> ethernet/atheros}/atlx/atl2.c     |    0
>  drivers/net/{ =3D> ethernet/atheros}/atlx/atl2.h     |    0
>  drivers/net/{ =3D> ethernet/atheros}/atlx/atlx.c     |    0
>  drivers/net/{ =3D> ethernet/atheros}/atlx/atlx.h     |    0
>  27 files changed, 72 insertions(+), 50 deletions(-)
>=20
> commit c97cb6d3434e3a3fa4d415f436e04475df39e443
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Fri May 20 00:04:35 2011 -0700
>=20
>     de6*/dl2k: Move the D-Link drivers
>=20
>     Move the D-Link drivers into drivers/net/ethernet/dlink/ and
>     make the necessary Kconfig and Makefile changes.
>=20
>     CC: Bjorn Ekwall <bj0rn@blox.se>
>     CC: Donald Becker <becker@scyld.com>
>     CC: Edward Peng <edward_peng@dlink.com.tw>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  drivers/net/Kconfig                      |   44 ----------------------
>  drivers/net/Makefile                     |    3 -
>  drivers/net/ethernet/Kconfig             |    1 +
>  drivers/net/ethernet/Makefile            |    1 +
>  drivers/net/ethernet/dlink/Kconfig       |   60 ++++++++++++++++++++++++=
++++++
>  drivers/net/ethernet/dlink/Makefile      |    7 +++
>  drivers/net/{ =3D> ethernet/dlink}/de600.c |    0
>  drivers/net/{ =3D> ethernet/dlink}/de600.h |    0
>  drivers/net/{ =3D> ethernet/dlink}/de620.c |    0
>  drivers/net/{ =3D> ethernet/dlink}/de620.h |    0
>  drivers/net/{ =3D> ethernet/dlink}/dl2k.c  |    0
>  drivers/net/{ =3D> ethernet/dlink}/dl2k.h  |    0
>  12 files changed, 69 insertions(+), 47 deletions(-)
>=20
> commit 268a0fa7d7159b37d1123d68343c555f44221510
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Thu May 19 23:27:55 2011 -0700
>=20
>     8139*/atp/r8169: Move the Realtek drivers
>=20
>     Move the Realtek drivers into drivers/net/ethernet/realtek/ and make
>     the necessary Kconfig and Makefile changes.
>=20
>     CC: Realtek linux nic maintainers <nic_swsd@realtek.com>
>     CC: Francois Romieu <romieu@fr.zoreil.com>
>     CC: Jeff Garzik <jgarzik@pobox.com>
>     CC: Donald Becker <becker@scyld.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                  |    2 +-
>  drivers/net/Kconfig                          |   94 --------------------=
--
>  drivers/net/Makefile                         |    4 -
>  drivers/net/ethernet/Kconfig                 |    1 +
>  drivers/net/ethernet/Makefile                |    1 +
>  drivers/net/{ =3D> ethernet/realtek}/8139cp.c  |    0
>  drivers/net/{ =3D> ethernet/realtek}/8139too.c |    0
>  drivers/net/ethernet/realtek/Kconfig         |  110 ++++++++++++++++++++=
++++++
>  drivers/net/ethernet/realtek/Makefile        |    8 ++
>  drivers/net/{ =3D> ethernet/realtek}/atp.c     |    0
>  drivers/net/{ =3D> ethernet/realtek}/atp.h     |    0
>  drivers/net/{ =3D> ethernet/realtek}/r8169.c   |    0
>  12 files changed, 121 insertions(+), 99 deletions(-)
>=20
> commit 5fe875b9e93af6b5a099b37471bebb541f1ba0c6
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Thu May 19 22:06:03 2011 -0700
>=20
>     arm: Move the ARM/ACORN drivers
>=20
>     Move the ARM/ACORN drivers into drivers/net/ethernet/arm/ and make th=
e
>     necessary Kconfig and Makefile changes.
>     There were 4 drivers (TI Davinci & ftmac100) not in the
>     drivers/net/arm/ which should have been since they are only supported
>     under ARM, so they were added to the new directory structure.
>=20
>     NOTE: There are no "maintainers" for the TI Davinci drivers, so I am
>     CC'ing the last 3 major contributors from TI.
>=20
>     CC: Sriram <srk@ti.com>
>     CC: Vinay Hegde <vinay.hegde@ti.com>
>     CC: Cyril Chemparathy <cyril@ti.com>
>     CC: Russell King <linux@arm.linux.org.uk>
>     CC: Wan ZongShun <mcuos.com@gmail.com>
>     CC: Lennert Buytenhek <kernel@wantstofly.org>
>     CC: Krzysztof Halasa <khc@pm.waw.pl>
>     CC: Po-Yu Chuang <ratbert@faraday-tech.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                    |   10 +-
>  drivers/net/Kconfig                            |   51 ---------
>  drivers/net/Makefile                           |    7 --
>  drivers/net/arm/Kconfig                        |   74 -------------
>  drivers/net/ethernet/Kconfig                   |    1 +
>  drivers/net/ethernet/Makefile                  |    1 +
>  drivers/net/ethernet/arm/Kconfig               |  138 ++++++++++++++++++=
++++++
>  drivers/net/{ =3D> ethernet}/arm/Makefile        |    6 +-
>  drivers/net/{ =3D> ethernet}/arm/am79c961a.c     |    0
>  drivers/net/{ =3D> ethernet}/arm/am79c961a.h     |    0
>  drivers/net/{ =3D> ethernet}/arm/at91_ether.c    |    0
>  drivers/net/{ =3D> ethernet}/arm/at91_ether.h    |    0
>  drivers/net/{ =3D> ethernet/arm}/davinci_cpdma.c |    0
>  drivers/net/{ =3D> ethernet/arm}/davinci_cpdma.h |    0
>  drivers/net/{ =3D> ethernet/arm}/davinci_emac.c  |    0
>  drivers/net/{ =3D> ethernet/arm}/davinci_mdio.c  |    0
>  drivers/net/{ =3D> ethernet}/arm/ep93xx_eth.c    |    0
>  drivers/net/{ =3D> ethernet}/arm/ether1.c        |    0
>  drivers/net/{ =3D> ethernet}/arm/ether1.h        |    0
>  drivers/net/{ =3D> ethernet}/arm/ether3.c        |    0
>  drivers/net/{ =3D> ethernet}/arm/ether3.h        |    0
>  drivers/net/{ =3D> ethernet}/arm/etherh.c        |    0
>  drivers/net/{ =3D> ethernet/arm}/ftgmac100.c     |    0
>  drivers/net/{ =3D> ethernet/arm}/ftgmac100.h     |    0
>  drivers/net/{ =3D> ethernet/arm}/ftmac100.c      |    0
>  drivers/net/{ =3D> ethernet/arm}/ftmac100.h      |    0
>  drivers/net/{ =3D> ethernet}/arm/ixp4xx_eth.c    |    0
>  drivers/net/{ =3D> ethernet}/arm/ks8695net.c     |    0
>  drivers/net/{ =3D> ethernet}/arm/ks8695net.h     |    0
>  drivers/net/{ =3D> ethernet}/arm/w90p910_ether.c |    0
>  30 files changed, 150 insertions(+), 138 deletions(-)
>=20
> commit 17c347d9648541503aef09b95b207737b151ddea
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Thu May 19 20:18:50 2011 -0700
>=20
>     smsc*/smc911x: Move the SMSC drivers
>=20
>     Move the SMSC drivers into drivers/net/ethernet/smsc/ and make the
>     necessary Kconfig and Makefile changes.
>=20
>     CC: Dustin McIntire <dustin@sensoria.com>
>     CC: Steve Glendinning <steve.glendinning@smsc.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                |    4 +-
>  drivers/net/Kconfig                        |   54 ---------------------
>  drivers/net/Makefile                       |    3 -
>  drivers/net/ethernet/Kconfig               |    1 +
>  drivers/net/ethernet/Makefile              |    1 +
>  drivers/net/ethernet/smsc/Kconfig          |   71 ++++++++++++++++++++++=
++++++
>  drivers/net/ethernet/smsc/Makefile         |    7 +++
>  drivers/net/{ =3D> ethernet/smsc}/smc911x.c  |    0
>  drivers/net/{ =3D> ethernet/smsc}/smc911x.h  |    0
>  drivers/net/{ =3D> ethernet/smsc}/smsc911x.c |    0
>  drivers/net/{ =3D> ethernet/smsc}/smsc911x.h |    0
>  drivers/net/{ =3D> ethernet/smsc}/smsc9420.c |    0
>  drivers/net/{ =3D> ethernet/smsc}/smsc9420.h |    0
>  13 files changed, 82 insertions(+), 59 deletions(-)
>=20
> commit f93707a2948f67da9fbe12ff93f6c5a95d6fb23d
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Wed May 18 05:14:22 2011 -0700
>=20
>     *sonic/natsemi/ns83829: Move the National Semi-conductor drivers
>=20
>     Move the National Semi-conductor drivers into drivers/net/ethernet/na=
tsemi/
>     and make the necessary Kconfig and Makefile changes.  Also moved the =
8390
>     (National Semi-conductor) devices as a sub-menu of National Semi-cond=
uctor
>     devices.
>=20
>     CC: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
>     CC: Harald Welte <laforge@gnumonks.org>
>     CC: Tim Hockin <thockin@hockin.org>
>     CC: <linux-ns83820@kvack.org>
>     CC: Kevin Chea <kchea@yahoo.com>
>     CC: Marc Gauthier <marc@linux-xtensa.org>
>     CC: Chris Zankel <chris@zankel.net>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                    |    4 +-
>  drivers/net/Kconfig                            |   47 ------------------
>  drivers/net/Makefile                           |    6 --
>  drivers/net/ethernet/8390/Kconfig              |    6 +-
>  drivers/net/ethernet/Kconfig                   |    3 +-
>  drivers/net/ethernet/Makefile                  |    1 +
>  drivers/net/ethernet/natsemi/Kconfig           |   63 ++++++++++++++++++=
++++++
>  drivers/net/ethernet/natsemi/Makefile          |    9 +++
>  drivers/net/{ =3D> ethernet/natsemi}/jazzsonic.c |    0
>  drivers/net/{ =3D> ethernet/natsemi}/macsonic.c  |    0
>  drivers/net/{ =3D> ethernet/natsemi}/natsemi.c   |    0
>  drivers/net/{ =3D> ethernet/natsemi}/ns83820.c   |    0
>  drivers/net/{ =3D> ethernet/natsemi}/sonic.c     |    0
>  drivers/net/{ =3D> ethernet/natsemi}/sonic.h     |    0
>  drivers/net/{ =3D> ethernet/natsemi}/xtsonic.c   |    0
>  15 files changed, 80 insertions(+), 59 deletions(-)
>=20
> commit 8a352394d237f49f4d142874057d4179a1169607
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Mon May 16 01:39:01 2011 -0700
>=20
>     bmac/mace/macmace/mac89x0/cs89x0: Move the Macintosh (Apple) drivers
>=20
>     Move the Apple drivers into driver/net/ethernet/apple/ and make the
>     necessary Kconfig and Makefile changes.
>=20
>     CC: Paul Mackerras <paulus@samba.org>
>     CC: Paul Mackerras <paulus@au.ibm.com>
>     CC: Russell Nelson <nelson@crynwr.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  drivers/net/Kconfig                        |   75 ----------------------
>  drivers/net/Makefile                       |    6 --
>  drivers/net/ethernet/Kconfig               |    1 +
>  drivers/net/ethernet/Makefile              |    1 +
>  drivers/net/ethernet/apple/Kconfig         |   92 ++++++++++++++++++++++=
++++++
>  drivers/net/ethernet/apple/Makefile        |    9 +++
>  drivers/net/{ =3D> ethernet/apple}/bmac.c    |    0
>  drivers/net/{ =3D> ethernet/apple}/bmac.h    |    0
>  drivers/net/{ =3D> ethernet/apple}/cs89x0.c  |    0
>  drivers/net/{ =3D> ethernet/apple}/cs89x0.h  |    0
>  drivers/net/{ =3D> ethernet/apple}/mac89x0.c |    0
>  drivers/net/{ =3D> ethernet/apple}/mace.c    |    0
>  drivers/net/{ =3D> ethernet/apple}/mace.h    |    0
>  drivers/net/{ =3D> ethernet/apple}/macmace.c |    0
>  14 files changed, 103 insertions(+), 81 deletions(-)
>=20
> commit 0222c318a10195f618d82f9f7c4e0d61564bcc5d
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Mon May 16 00:05:19 2011 -0700
>=20
>     stmmac: Move the STMicroelectronics driver
>=20
>     Move the STMicroelectronics driver into driver/net/ethernet/stmmac/ a=
nd
>     make the necessary Kconfig and Makefile changes.
>=20
>     CC: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                        |    2 +-
>  drivers/net/Kconfig                                |    2 --
>  drivers/net/Makefile                               |    1 -
>  drivers/net/ethernet/Kconfig                       |    1 +
>  drivers/net/ethernet/Makefile                      |    1 +
>  drivers/net/{ =3D> ethernet}/stmmac/Kconfig          |    0
>  drivers/net/{ =3D> ethernet}/stmmac/Makefile         |    0
>  drivers/net/{ =3D> ethernet}/stmmac/common.h         |    0
>  drivers/net/{ =3D> ethernet}/stmmac/descs.h          |    0
>  drivers/net/{ =3D> ethernet}/stmmac/dwmac100.h       |    0
>  drivers/net/{ =3D> ethernet}/stmmac/dwmac1000.h      |    0
>  drivers/net/{ =3D> ethernet}/stmmac/dwmac1000_core.c |    0
>  drivers/net/{ =3D> ethernet}/stmmac/dwmac1000_dma.c  |    0
>  drivers/net/{ =3D> ethernet}/stmmac/dwmac100_core.c  |    0
>  drivers/net/{ =3D> ethernet}/stmmac/dwmac100_dma.c   |    0
>  drivers/net/{ =3D> ethernet}/stmmac/dwmac_dma.h      |    0
>  drivers/net/{ =3D> ethernet}/stmmac/dwmac_lib.c      |    0
>  drivers/net/{ =3D> ethernet}/stmmac/enh_desc.c       |    0
>  drivers/net/{ =3D> ethernet}/stmmac/norm_desc.c      |    0
>  drivers/net/{ =3D> ethernet}/stmmac/stmmac.h         |    0
>  drivers/net/{ =3D> ethernet}/stmmac/stmmac_ethtool.c |    0
>  drivers/net/{ =3D> ethernet}/stmmac/stmmac_main.c    |    0
>  drivers/net/{ =3D> ethernet}/stmmac/stmmac_mdio.c    |    0
>  drivers/net/{ =3D> ethernet}/stmmac/stmmac_timer.c   |    0
>  drivers/net/{ =3D> ethernet}/stmmac/stmmac_timer.h   |    0
>  25 files changed, 3 insertions(+), 4 deletions(-)
>=20
> commit c9979075eda1f39b3cf73b51b4da05e2bc1a7a3f
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Sun May 15 21:46:41 2011 -0700
>=20
>     tehuti: Move the Tehuti driver
>=20
>     Move the Tehuti driver into drivers/net/ethernet/ and make the
>     necessary Kconfig and Makefile changes.
>=20
>     CC: Alexander Indenbaum <baum@tehutinetworks.net>
>     CC: Andy Gospodarek <andy@greyhouse.net>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                         |    2 +-
>  drivers/net/Kconfig                 |    6 ------
>  drivers/net/Makefile                |    1 -
>  drivers/net/ethernet/Kconfig        |    6 ++++++
>  drivers/net/ethernet/Makefile       |    1 +
>  drivers/net/{ =3D> ethernet}/tehuti.c |    0
>  drivers/net/{ =3D> ethernet}/tehuti.h |    0
>  7 files changed, 8 insertions(+), 8 deletions(-)
>=20
> commit 9b8448aa63ea26e8cbe23df6064146b2bcf1429c
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Sun May 15 20:56:37 2011 -0700
>=20
>     pasemic_mac*: Move the PA Semi driver
>=20
>     Move the PA Semi driver into drivers/net/ethernet/ and make the
>     necessary Kconfig and Makefile changes.
>=20
>     CC: Olof Johansson <olof@lixom.net>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                     |    2 +-
>  drivers/net/Kconfig                             |    9 ---------
>  drivers/net/Makefile                            |    2 --
>  drivers/net/ethernet/Kconfig                    |   10 ++++++++++
>  drivers/net/ethernet/Makefile                   |    1 +
>  drivers/net/{ =3D> ethernet}/pasemi_mac.c         |    0
>  drivers/net/{ =3D> ethernet}/pasemi_mac.h         |    0
>  drivers/net/{ =3D> ethernet}/pasemi_mac_ethtool.c |    0
>  8 files changed, 12 insertions(+), 12 deletions(-)
>=20
> commit 8f45b84e5a50e13e530ccd7277e87e21bf9d3824
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Fri May 13 22:20:35 2011 -0700
>=20
>     enic: Move the Cisco driver
>=20
>     Move the Cisco driver into drivers/net/ethernet/enic/ and make the
>     necessary Kconfig and Makefile changes.
>=20
>     CC: Scott Feldman <scofeldm@cisco.com>
>     CC: Christian Benvenuti <benve@cisco.com>
>     CC: Vasanthy Kolluri <vkolluri@cisco.com>
>     CC: Roopa Prabhu <roprabhu@cisco.com>
>     CC: David Wang <dwang2@cisco.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                     |    2 +-
>  drivers/net/Kconfig                             |    6 ------
>  drivers/net/Makefile                            |    1 -
>  drivers/net/ethernet/Kconfig                    |    1 +
>  drivers/net/ethernet/Makefile                   |    1 +
>  drivers/net/ethernet/enic/Kconfig               |    9 +++++++++
>  drivers/net/{ =3D> ethernet}/enic/Makefile        |    0
>  drivers/net/{ =3D> ethernet}/enic/cq_desc.h       |    0
>  drivers/net/{ =3D> ethernet}/enic/cq_enet_desc.h  |    0
>  drivers/net/{ =3D> ethernet}/enic/enic.h          |    0
>  drivers/net/{ =3D> ethernet}/enic/enic_dev.c      |    0
>  drivers/net/{ =3D> ethernet}/enic/enic_dev.h      |    0
>  drivers/net/{ =3D> ethernet}/enic/enic_main.c     |    0
>  drivers/net/{ =3D> ethernet}/enic/enic_pp.c       |    0
>  drivers/net/{ =3D> ethernet}/enic/enic_pp.h       |    0
>  drivers/net/{ =3D> ethernet}/enic/enic_res.c      |    0
>  drivers/net/{ =3D> ethernet}/enic/enic_res.h      |    0
>  drivers/net/{ =3D> ethernet}/enic/rq_enet_desc.h  |    0
>  drivers/net/{ =3D> ethernet}/enic/vnic_cq.c       |    0
>  drivers/net/{ =3D> ethernet}/enic/vnic_cq.h       |    0
>  drivers/net/{ =3D> ethernet}/enic/vnic_dev.c      |    0
>  drivers/net/{ =3D> ethernet}/enic/vnic_dev.h      |    0
>  drivers/net/{ =3D> ethernet}/enic/vnic_devcmd.h   |    0
>  drivers/net/{ =3D> ethernet}/enic/vnic_enet.h     |    0
>  drivers/net/{ =3D> ethernet}/enic/vnic_intr.c     |    0
>  drivers/net/{ =3D> ethernet}/enic/vnic_intr.h     |    0
>  drivers/net/{ =3D> ethernet}/enic/vnic_nic.h      |    0
>  drivers/net/{ =3D> ethernet}/enic/vnic_resource.h |    0
>  drivers/net/{ =3D> ethernet}/enic/vnic_rq.c       |    0
>  drivers/net/{ =3D> ethernet}/enic/vnic_rq.h       |    0
>  drivers/net/{ =3D> ethernet}/enic/vnic_rss.h      |    0
>  drivers/net/{ =3D> ethernet}/enic/vnic_stats.h    |    0
>  drivers/net/{ =3D> ethernet}/enic/vnic_vic.c      |    0
>  drivers/net/{ =3D> ethernet}/enic/vnic_vic.h      |    0
>  drivers/net/{ =3D> ethernet}/enic/vnic_wq.c       |    0
>  drivers/net/{ =3D> ethernet}/enic/vnic_wq.h       |    0
>  drivers/net/{ =3D> ethernet}/enic/wq_enet_desc.h  |    0
>  37 files changed, 12 insertions(+), 8 deletions(-)
>=20
> commit 21b49617eef3976ebbd73cb4bf1a1f2f6902dbbf
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Fri May 13 14:29:12 2011 -0700
>=20
>     ehea/ibm*: Move the IBM drivers
>=20
>     Move the IBM drivers into drivers/net/ethernet/ibm/ and make the
>     necessary Kconfig and Makefile changes.
>=20
>     CC: Christoph Raisch <raisch@de.ibm.com>
>     CC: Alfred Arnold <alfred.arnold@lancom.de>
>     CC: Santiago Leon <santil@linux.vnet.ibm.com>
>     CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                        |    4 +-
>  drivers/net/Kconfig                                |   37 --------------
>  drivers/net/Makefile                               |    4 --
>  drivers/net/ethernet/Kconfig                       |    1 +
>  drivers/net/ethernet/Makefile                      |    1 +
>  drivers/net/ethernet/ibm/Kconfig                   |   53 ++++++++++++++=
++++++
>  drivers/net/ethernet/ibm/Makefile                  |    8 +++
>  drivers/net/{ =3D> ethernet/ibm}/ehea/Makefile       |    0
>  drivers/net/{ =3D> ethernet/ibm}/ehea/ehea.h         |    0
>  drivers/net/{ =3D> ethernet/ibm}/ehea/ehea_ethtool.c |    0
>  drivers/net/{ =3D> ethernet/ibm}/ehea/ehea_hw.h      |    0
>  drivers/net/{ =3D> ethernet/ibm}/ehea/ehea_main.c    |    0
>  drivers/net/{ =3D> ethernet/ibm}/ehea/ehea_phyp.c    |    0
>  drivers/net/{ =3D> ethernet/ibm}/ehea/ehea_phyp.h    |    0
>  drivers/net/{ =3D> ethernet/ibm}/ehea/ehea_qmr.c     |    0
>  drivers/net/{ =3D> ethernet/ibm}/ehea/ehea_qmr.h     |    0
>  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/Kconfig |    2 +-
>  .../net/{ =3D> ethernet/ibm}/ibm_newemac/Makefile    |    0
>  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/core.c  |    0
>  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/core.h  |    0
>  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/debug.c |    0
>  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/debug.h |    0
>  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/emac.h  |    0
>  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/mal.c   |    0
>  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/mal.h   |    0
>  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/phy.c   |    0
>  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/phy.h   |    0
>  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/rgmii.c |    0
>  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/rgmii.h |    0
>  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/tah.c   |    0
>  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/tah.h   |    0
>  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/zmii.c  |    0
>  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/zmii.h  |    0
>  drivers/net/{ =3D> ethernet/ibm}/ibmlana.c           |    0
>  drivers/net/{ =3D> ethernet/ibm}/ibmlana.h           |    0
>  drivers/net/{ =3D> ethernet/ibm}/ibmveth.c           |    0
>  drivers/net/{ =3D> ethernet/ibm}/ibmveth.h           |    0
>  37 files changed, 66 insertions(+), 44 deletions(-)
>=20
> commit a5c1daab860bc137dafadc061e48f4153ce89a31
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Fri May 13 02:51:01 2011 -0700
>=20
>     s2io/vxge: Move the Exar drivers
>=20
>     Move the Exar drivers into drivers/net/ethernet/exar/ and make the
>     necessary Kconfig and Makefile changes.
>=20
>     CC: Jon Mason <jdmason@kudzu.us>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                        |    3 +-
>  drivers/net/Kconfig                                |   34 -------------
>  drivers/net/Makefile                               |    2 -
>  drivers/net/ethernet/Kconfig                       |    1 +
>  drivers/net/ethernet/Makefile                      |    1 +
>  drivers/net/ethernet/exar/Kconfig                  |   50 ++++++++++++++=
++++++
>  drivers/net/ethernet/exar/Makefile                 |    6 ++
>  drivers/net/{ =3D> ethernet/exar}/s2io-regs.h        |    0
>  drivers/net/{ =3D> ethernet/exar}/s2io.c             |    0
>  drivers/net/{ =3D> ethernet/exar}/s2io.h             |    0
>  drivers/net/{ =3D> ethernet/exar}/vxge/Makefile      |    0
>  drivers/net/{ =3D> ethernet/exar}/vxge/vxge-config.c |    0
>  drivers/net/{ =3D> ethernet/exar}/vxge/vxge-config.h |    0
>  .../net/{ =3D> ethernet/exar}/vxge/vxge-ethtool.c    |    0
>  .../net/{ =3D> ethernet/exar}/vxge/vxge-ethtool.h    |    0
>  drivers/net/{ =3D> ethernet/exar}/vxge/vxge-main.c   |    0
>  drivers/net/{ =3D> ethernet/exar}/vxge/vxge-main.h   |    0
>  drivers/net/{ =3D> ethernet/exar}/vxge/vxge-reg.h    |    0
>  .../net/{ =3D> ethernet/exar}/vxge/vxge-traffic.c    |    0
>  .../net/{ =3D> ethernet/exar}/vxge/vxge-traffic.h    |    0
>  .../net/{ =3D> ethernet/exar}/vxge/vxge-version.h    |    0
>  21 files changed, 59 insertions(+), 38 deletions(-)
>=20
> commit 83df87d655e25119eafaeb4225bc5eedaa82c6e0
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Fri May 13 02:24:46 2011 -0700
>=20
>     myri*: Move the Myricom drivers
>=20
>     Move the Myricom drivers into drivers/net/ethernet/myricom/ and make
>     the necessary Kconfig and Makefile changes.
>=20
>     CC: Andrew Gallatin <gallatin@myri.com>
>     CC: Brice Goglin <brice@myri.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                        |    2 +-
>  drivers/net/Kconfig                                |   35 -------------
>  drivers/net/Makefile                               |    3 -
>  drivers/net/ethernet/Kconfig                       |    1 +
>  drivers/net/ethernet/Makefile                      |    1 +
>  drivers/net/ethernet/myricom/Kconfig               |   51 ++++++++++++++=
++++++
>  drivers/net/ethernet/myricom/Makefile              |    6 ++
>  .../net/{ =3D> ethernet/myricom}/myri10ge/Makefile   |    0
>  .../net/{ =3D> ethernet/myricom}/myri10ge/myri10ge.c |    0
>  .../{ =3D> ethernet/myricom}/myri10ge/myri10ge_mcp.h |    0
>  .../myricom}/myri10ge/myri10ge_mcp_gen_header.h    |    0
>  drivers/net/{ =3D> ethernet/myricom}/myri_sbus.c     |    0
>  drivers/net/{ =3D> ethernet/myricom}/myri_sbus.h     |    0
>  13 files changed, 60 insertions(+), 39 deletions(-)
>=20
> commit c04bd079e4ab82c5ee8fd0cb526f16e9ffce9360
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Fri May 13 01:32:22 2011 -0700
>=20
>     mlx4: Move the Mellanox driver
>=20
>     Moves the Mellanox driver into drivers/net/ethernet/mlx4/ and make
>     the necessary Kconfig and Makefile changes.
>=20
>     CC: Roland Dreier <roland@kernel.org>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  drivers/net/Kconfig                            |   24 ------------------=
---
>  drivers/net/Makefile                           |    1 -
>  drivers/net/ethernet/Kconfig                   |    1 +
>  drivers/net/ethernet/Makefile                  |    1 +
>  drivers/net/ethernet/mlx4/Kconfig              |   27 ++++++++++++++++++=
++++++
>  drivers/net/{ =3D> ethernet}/mlx4/Makefile       |    0
>  drivers/net/{ =3D> ethernet}/mlx4/alloc.c        |    0
>  drivers/net/{ =3D> ethernet}/mlx4/catas.c        |    0
>  drivers/net/{ =3D> ethernet}/mlx4/cmd.c          |    0
>  drivers/net/{ =3D> ethernet}/mlx4/cq.c           |    0
>  drivers/net/{ =3D> ethernet}/mlx4/en_cq.c        |    0
>  drivers/net/{ =3D> ethernet}/mlx4/en_ethtool.c   |    0
>  drivers/net/{ =3D> ethernet}/mlx4/en_main.c      |    0
>  drivers/net/{ =3D> ethernet}/mlx4/en_netdev.c    |    0
>  drivers/net/{ =3D> ethernet}/mlx4/en_port.c      |    0
>  drivers/net/{ =3D> ethernet}/mlx4/en_port.h      |    0
>  drivers/net/{ =3D> ethernet}/mlx4/en_resources.c |    0
>  drivers/net/{ =3D> ethernet}/mlx4/en_rx.c        |    0
>  drivers/net/{ =3D> ethernet}/mlx4/en_selftest.c  |    0
>  drivers/net/{ =3D> ethernet}/mlx4/en_tx.c        |    0
>  drivers/net/{ =3D> ethernet}/mlx4/eq.c           |    0
>  drivers/net/{ =3D> ethernet}/mlx4/fw.c           |    0
>  drivers/net/{ =3D> ethernet}/mlx4/fw.h           |    0
>  drivers/net/{ =3D> ethernet}/mlx4/icm.c          |    0
>  drivers/net/{ =3D> ethernet}/mlx4/icm.h          |    0
>  drivers/net/{ =3D> ethernet}/mlx4/intf.c         |    0
>  drivers/net/{ =3D> ethernet}/mlx4/main.c         |    0
>  drivers/net/{ =3D> ethernet}/mlx4/mcg.c          |    0
>  drivers/net/{ =3D> ethernet}/mlx4/mlx4.h         |    0
>  drivers/net/{ =3D> ethernet}/mlx4/mlx4_en.h      |    0
>  drivers/net/{ =3D> ethernet}/mlx4/mr.c           |    0
>  drivers/net/{ =3D> ethernet}/mlx4/pd.c           |    0
>  drivers/net/{ =3D> ethernet}/mlx4/port.c         |    0
>  drivers/net/{ =3D> ethernet}/mlx4/profile.c      |    0
>  drivers/net/{ =3D> ethernet}/mlx4/qp.c           |    0
>  drivers/net/{ =3D> ethernet}/mlx4/reset.c        |    0
>  drivers/net/{ =3D> ethernet}/mlx4/sense.c        |    0
>  drivers/net/{ =3D> ethernet}/mlx4/srq.c          |    0
>  38 files changed, 29 insertions(+), 25 deletions(-)
>=20
> commit d911fd7be681f8833f8ff12efade39df79970653
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Fri May 13 01:00:03 2011 -0700
>=20
>     bna: Move the Brocade driver
>=20
>     Moves the Brocade driver into drivers/net/ethernet/bna/ and make
>     the necessary Kconfig and Makefile changes.
>=20
>     CC: Rasesh Mody <rmody@brocade.com>
>     CC: Debashis Dutt <ddutt@brocade.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                        |    2 +-
>  drivers/net/Kconfig                                |   14 --------------
>  drivers/net/Makefile                               |    1 -
>  drivers/net/ethernet/Kconfig                       |    1 +
>  drivers/net/ethernet/Makefile                      |    1 +
>  drivers/net/ethernet/bna/Kconfig                   |   17 ++++++++++++++=
+++
>  drivers/net/{ =3D> ethernet}/bna/Makefile            |    0
>  drivers/net/{ =3D> ethernet}/bna/bfa_cee.c           |    0
>  drivers/net/{ =3D> ethernet}/bna/bfa_cee.h           |    0
>  drivers/net/{ =3D> ethernet}/bna/bfa_defs.h          |    0
>  drivers/net/{ =3D> ethernet}/bna/bfa_defs_cna.h      |    0
>  drivers/net/{ =3D> ethernet}/bna/bfa_defs_mfg_comm.h |    0
>  drivers/net/{ =3D> ethernet}/bna/bfa_defs_status.h   |    0
>  drivers/net/{ =3D> ethernet}/bna/bfa_ioc.c           |    0
>  drivers/net/{ =3D> ethernet}/bna/bfa_ioc.h           |    0
>  drivers/net/{ =3D> ethernet}/bna/bfa_ioc_ct.c        |    0
>  drivers/net/{ =3D> ethernet}/bna/bfa_sm.h            |    0
>  drivers/net/{ =3D> ethernet}/bna/bfa_wc.h            |    0
>  drivers/net/{ =3D> ethernet}/bna/bfi.h               |    0
>  drivers/net/{ =3D> ethernet}/bna/bfi_cna.h           |    0
>  drivers/net/{ =3D> ethernet}/bna/bfi_ctreg.h         |    0
>  drivers/net/{ =3D> ethernet}/bna/bfi_ll.h            |    0
>  drivers/net/{ =3D> ethernet}/bna/bna.h               |    0
>  drivers/net/{ =3D> ethernet}/bna/bna_ctrl.c          |    0
>  drivers/net/{ =3D> ethernet}/bna/bna_hw.h            |    0
>  drivers/net/{ =3D> ethernet}/bna/bna_txrx.c          |    0
>  drivers/net/{ =3D> ethernet}/bna/bna_types.h         |    0
>  drivers/net/{ =3D> ethernet}/bna/bnad.c              |    0
>  drivers/net/{ =3D> ethernet}/bna/bnad.h              |    0
>  drivers/net/{ =3D> ethernet}/bna/bnad_ethtool.c      |    0
>  drivers/net/{ =3D> ethernet}/bna/cna.h               |    0
>  drivers/net/{ =3D> ethernet}/bna/cna_fwimg.c         |    0
>  32 files changed, 20 insertions(+), 16 deletions(-)
>=20
> commit 931da59411e60574a1235d0ad2d63ebd1638a859
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Fri May 13 00:37:27 2011 -0700
>=20
>     be2net: Move the BladeEngine 2 driver
>=20
>     Moves the Server Engine driver into drivers/net/ethernet/benet/ and
>     make the necessary Kconfig and Makefile changes.
>=20
>     CC: Sathya Perla <sathya.perla@emulex.com>
>     CC: Subbu Seetharaman <subbu.seetharaman@emulex.com>
>     CC: Ajit Khaparde <ajit.khaparde@emulex.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                   |    2 +-
>  drivers/net/Kconfig                           |    2 --
>  drivers/net/Makefile                          |    1 -
>  drivers/net/ethernet/Kconfig                  |    1 +
>  drivers/net/ethernet/Makefile                 |    1 +
>  drivers/net/{ =3D> ethernet}/benet/Kconfig      |    0
>  drivers/net/{ =3D> ethernet}/benet/Makefile     |    0
>  drivers/net/{ =3D> ethernet}/benet/be.h         |    0
>  drivers/net/{ =3D> ethernet}/benet/be_cmds.c    |    0
>  drivers/net/{ =3D> ethernet}/benet/be_cmds.h    |    0
>  drivers/net/{ =3D> ethernet}/benet/be_ethtool.c |    0
>  drivers/net/{ =3D> ethernet}/benet/be_hw.h      |    0
>  drivers/net/{ =3D> ethernet}/benet/be_main.c    |    0
>  13 files changed, 3 insertions(+), 4 deletions(-)
>=20
> commit 64648e513185522cd665bfece6d024d3c05588ed
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Fri May 13 00:17:42 2011 -0700
>=20
>     sfc: Move the Solarflare drivers
>=20
>     Moves the Solarflare drivers into drivers/net/ethernet/sfc/ and
>     make the necessary Kconfig and Makefile changes.
>=20
>     CC: Steve Hodgson <shodgson@solarflare.com>
>     CC: Ben Hutchings <bhutchings@solarflare.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                    |    2 +-
>  drivers/net/Kconfig                            |    2 --
>  drivers/net/Makefile                           |    1 -
>  drivers/net/ethernet/Kconfig                   |    1 +
>  drivers/net/ethernet/Makefile                  |    1 +
>  drivers/net/{ =3D> ethernet}/sfc/Kconfig         |    0
>  drivers/net/{ =3D> ethernet}/sfc/Makefile        |    0
>  drivers/net/{ =3D> ethernet}/sfc/bitfield.h      |    0
>  drivers/net/{ =3D> ethernet}/sfc/efx.c           |    0
>  drivers/net/{ =3D> ethernet}/sfc/efx.h           |    0
>  drivers/net/{ =3D> ethernet}/sfc/enum.h          |    0
>  drivers/net/{ =3D> ethernet}/sfc/ethtool.c       |    0
>  drivers/net/{ =3D> ethernet}/sfc/falcon.c        |    0
>  drivers/net/{ =3D> ethernet}/sfc/falcon_boards.c |    0
>  drivers/net/{ =3D> ethernet}/sfc/falcon_xmac.c   |    0
>  drivers/net/{ =3D> ethernet}/sfc/filter.c        |    0
>  drivers/net/{ =3D> ethernet}/sfc/filter.h        |    0
>  drivers/net/{ =3D> ethernet}/sfc/io.h            |    0
>  drivers/net/{ =3D> ethernet}/sfc/mac.h           |    0
>  drivers/net/{ =3D> ethernet}/sfc/mcdi.c          |    0
>  drivers/net/{ =3D> ethernet}/sfc/mcdi.h          |    0
>  drivers/net/{ =3D> ethernet}/sfc/mcdi_mac.c      |    0
>  drivers/net/{ =3D> ethernet}/sfc/mcdi_pcol.h     |    0
>  drivers/net/{ =3D> ethernet}/sfc/mcdi_phy.c      |    0
>  drivers/net/{ =3D> ethernet}/sfc/mdio_10g.c      |    0
>  drivers/net/{ =3D> ethernet}/sfc/mdio_10g.h      |    0
>  drivers/net/{ =3D> ethernet}/sfc/mtd.c           |    0
>  drivers/net/{ =3D> ethernet}/sfc/net_driver.h    |    0
>  drivers/net/{ =3D> ethernet}/sfc/nic.c           |    0
>  drivers/net/{ =3D> ethernet}/sfc/nic.h           |    0
>  drivers/net/{ =3D> ethernet}/sfc/phy.h           |    0
>  drivers/net/{ =3D> ethernet}/sfc/qt202x_phy.c    |    0
>  drivers/net/{ =3D> ethernet}/sfc/regs.h          |    0
>  drivers/net/{ =3D> ethernet}/sfc/rx.c            |    0
>  drivers/net/{ =3D> ethernet}/sfc/selftest.c      |    0
>  drivers/net/{ =3D> ethernet}/sfc/selftest.h      |    0
>  drivers/net/{ =3D> ethernet}/sfc/siena.c         |    0
>  drivers/net/{ =3D> ethernet}/sfc/spi.h           |    0
>  drivers/net/{ =3D> ethernet}/sfc/tenxpress.c     |    0
>  drivers/net/{ =3D> ethernet}/sfc/tx.c            |    0
>  drivers/net/{ =3D> ethernet}/sfc/txc43128_phy.c  |    0
>  drivers/net/{ =3D> ethernet}/sfc/workarounds.h   |    0
>  42 files changed, 3 insertions(+), 4 deletions(-)
>=20
> commit a9f8e9475d4f7c91880050634e923d62e369a0ed
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Thu May 12 23:04:46 2011 -0700
>=20
>     cassini/niu/sun*: Move the Sun drivers
>=20
>     Moves the Sun drivers into drivers/net/ethernet/sun/ and make
>     the necessary Kconfig and Makefile changes.
>=20
>     CC: Sam Creasey <sammy@sammy.net>
>     CC: Adrian Sun <asun@darksunrising.com>
>     CC: Benjamin Herrenscmidt <benh@kernel.crashing.org>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                 |    1 +
>  drivers/net/Kconfig                         |   75 ---------------------=
-
>  drivers/net/Makefile                        |   10 +---
>  drivers/net/ethernet/Kconfig                |    1 +
>  drivers/net/ethernet/Makefile               |    1 +
>  drivers/net/ethernet/sun/Kconfig            |   91 +++++++++++++++++++++=
++++++
>  drivers/net/ethernet/sun/Makefile           |   12 ++++
>  drivers/net/{ =3D> ethernet/sun}/cassini.c    |    0
>  drivers/net/{ =3D> ethernet/sun}/cassini.h    |    0
>  drivers/net/{ =3D> ethernet/sun}/niu.c        |    0
>  drivers/net/{ =3D> ethernet/sun}/niu.h        |    0
>  drivers/net/{ =3D> ethernet/sun}/sun3_82586.c |    0
>  drivers/net/{ =3D> ethernet/sun}/sun3_82586.h |    0
>  drivers/net/{ =3D> ethernet/sun}/sunbmac.c    |    0
>  drivers/net/{ =3D> ethernet/sun}/sunbmac.h    |    0
>  drivers/net/{ =3D> ethernet/sun}/sungem.c     |    0
>  drivers/net/{ =3D> ethernet/sun}/sungem.h     |    0
>  drivers/net/{ =3D> ethernet/sun}/sungem_phy.c |    0
>  drivers/net/{ =3D> ethernet/sun}/sungem_phy.h |    0
>  drivers/net/{ =3D> ethernet/sun}/sunhme.c     |    0
>  drivers/net/{ =3D> ethernet/sun}/sunhme.h     |    0
>  drivers/net/{ =3D> ethernet/sun}/sunqe.c      |    0
>  drivers/net/{ =3D> ethernet/sun}/sunqe.h      |    0
>  drivers/net/{ =3D> ethernet/sun}/sunvnet.c    |    0
>  drivers/net/{ =3D> ethernet/sun}/sunvnet.h    |    0
>  drivers/net/spider_net.h                    |    2 +-
>  26 files changed, 108 insertions(+), 85 deletions(-)
>=20
> commit c1b4800864efcbacb0f02047609b41c9ab5290e6
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Thu May 12 21:21:33 2011 -0700
>=20
>     ni5*/ni65: Move the Racal-Interlan (Micom) drivers
>=20
>     Moves the Racal-Interlan drivers into drivers/net/ethernet/racal/ and
>     make the necessary Kconfig and Makefile changes.
>=20
>     CC: "Jan-Pascal van Best" <janpascal@vanbest.org>
>     CC: Andreas Mohr <andi@lisas.de>
>     CC: "M.Hipp" <hippm@informatik.uni-tuebingen.de>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                               |    2 +-
>  drivers/net/Kconfig                       |   47 -----------------------=
----
>  drivers/net/Makefile                      |    3 --
>  drivers/net/ethernet/Kconfig              |    1 +
>  drivers/net/ethernet/Makefile             |    1 +
>  drivers/net/ethernet/racal/Kconfig        |   50 +++++++++++++++++++++++=
++++++
>  drivers/net/ethernet/racal/Makefile       |    7 ++++
>  drivers/net/{ =3D> ethernet/racal}/ni5010.c |    0
>  drivers/net/{ =3D> ethernet/racal}/ni5010.h |    0
>  drivers/net/{ =3D> ethernet/racal}/ni52.c   |    0
>  drivers/net/{ =3D> ethernet/racal}/ni52.h   |    0
>  drivers/net/{ =3D> ethernet/racal}/ni65.c   |    0
>  drivers/net/{ =3D> ethernet/racal}/ni65.h   |    0
>  13 files changed, 60 insertions(+), 51 deletions(-)
>=20
> commit 671dc5b8fb145ff8748cdc2aeffd1ef56af8bd67
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Thu May 12 20:21:07 2011 -0700
>=20
>     smc: Move the SMC drivers
>=20
>     Moves the SMC drivers into drivers/net/ethernet/smc/ and the
>     necessary Kconfig and Makefile changes.  Also did some cleanup
>     of NET_VENDOR_SMC Kconfig tag for the 8390 based drivers.
>=20
>     CC: Nicolas Pitre <nico@fluxnic.net>
>     CC: Donald Becker <becker@scyld.com>
>     CC: Erik Stahlman <erik@vt.edu>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                              |    2 +-
>  drivers/net/Kconfig                      |   51 ------------------------=
-
>  drivers/net/Makefile                     |    4 --
>  drivers/net/ethernet/8390/Kconfig        |   21 ++--------
>  drivers/net/ethernet/Kconfig             |    1 +
>  drivers/net/ethernet/Makefile            |    1 +
>  drivers/net/ethernet/qlogic/Kconfig      |    7 +++
>  drivers/net/ethernet/qlogic/Makefile     |    1 +
>  drivers/net/ethernet/smc/Kconfig         |   61 ++++++++++++++++++++++++=
++++++
>  drivers/net/ethernet/smc/Makefile        |    7 +++
>  drivers/net/{ =3D> ethernet/smc}/epic100.c |    0
>  drivers/net/{ =3D> ethernet/smc}/smc9194.c |    0
>  drivers/net/{ =3D> ethernet/smc}/smc9194.h |    0
>  drivers/net/{ =3D> ethernet/smc}/smc91x.c  |    0
>  drivers/net/{ =3D> ethernet/smc}/smc91x.h  |    0
>  15 files changed, 83 insertions(+), 73 deletions(-)
>=20
> commit e9f8a5c9b5f8f469bcfae06ddd10e9dc9537f7bb
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Fri Apr 8 19:06:30 2011 -0700
>=20
>     qlogic: Move the QLogic drivers
>=20
>     Moves the QLogic drivers into drivers/net/ethernet/qlogic/ and
>     the necessary Kconfig and Makefile changes.
>=20
>     CC: Ron Mercer <ron.mercer@qlogic.com>
>     CC: Amit Kumar Salecha <amit.salecha@qlogic.com>
>     CC: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                        |    6 +-
>  drivers/net/Kconfig                                |   26 ------------
>  drivers/net/Makefile                               |    3 -
>  drivers/net/ethernet/Kconfig                       |    1 +
>  drivers/net/ethernet/Makefile                      |    1 +
>  drivers/net/ethernet/qlogic/Kconfig                |   42 ++++++++++++++=
++++++
>  drivers/net/ethernet/qlogic/Makefile               |    7 +++
>  drivers/net/{ =3D> ethernet/qlogic}/netxen/Makefile  |    0
>  .../net/{ =3D> ethernet/qlogic}/netxen/netxen_nic.h  |    0
>  .../{ =3D> ethernet/qlogic}/netxen/netxen_nic_ctx.c  |    0
>  .../qlogic}/netxen/netxen_nic_ethtool.c            |    0
>  .../{ =3D> ethernet/qlogic}/netxen/netxen_nic_hdr.h  |    0
>  .../{ =3D> ethernet/qlogic}/netxen/netxen_nic_hw.c   |    0
>  .../{ =3D> ethernet/qlogic}/netxen/netxen_nic_hw.h   |    0
>  .../{ =3D> ethernet/qlogic}/netxen/netxen_nic_init.c |    0
>  .../{ =3D> ethernet/qlogic}/netxen/netxen_nic_main.c |    0
>  drivers/net/{ =3D> ethernet/qlogic}/qla3xxx.c        |    0
>  drivers/net/{ =3D> ethernet/qlogic}/qla3xxx.h        |    0
>  drivers/net/{ =3D> ethernet/qlogic}/qlcnic/Makefile  |    0
>  drivers/net/{ =3D> ethernet/qlogic}/qlcnic/qlcnic.h  |    0
>  .../net/{ =3D> ethernet/qlogic}/qlcnic/qlcnic_ctx.c  |    0
>  .../{ =3D> ethernet/qlogic}/qlcnic/qlcnic_ethtool.c  |    0
>  .../net/{ =3D> ethernet/qlogic}/qlcnic/qlcnic_hdr.h  |    0
>  .../net/{ =3D> ethernet/qlogic}/qlcnic/qlcnic_hw.c   |    0
>  .../net/{ =3D> ethernet/qlogic}/qlcnic/qlcnic_init.c |    0
>  .../net/{ =3D> ethernet/qlogic}/qlcnic/qlcnic_main.c |    0
>  drivers/net/{ =3D> ethernet/qlogic}/qlge/Makefile    |    0
>  drivers/net/{ =3D> ethernet/qlogic}/qlge/qlge.h      |    0
>  drivers/net/{ =3D> ethernet/qlogic}/qlge/qlge_dbg.c  |    0
>  .../net/{ =3D> ethernet/qlogic}/qlge/qlge_ethtool.c  |    0
>  drivers/net/{ =3D> ethernet/qlogic}/qlge/qlge_main.c |    0
>  drivers/net/{ =3D> ethernet/qlogic}/qlge/qlge_mpi.c  |    0
>  32 files changed, 54 insertions(+), 32 deletions(-)
>=20
> commit f8e68b0056ef20887bdfdc31ff061d67e81308e2
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Thu Apr 7 07:42:33 2011 -0700
>=20
>     intel: Move the Intel wired LAN drivers
>=20
>     Moves the Intel wired LAN drivers into drivers/net/ethernet/intel/ an=
d
>     the necessary Kconfig and Makefile changes.
>=20
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                        |   11 +-
>  drivers/net/Kconfig                                |  200 --------------=
----
>  drivers/net/Makefile                               |    8 -
>  drivers/net/ethernet/Kconfig                       |    1 +
>  drivers/net/ethernet/Makefile                      |    1 +
>  drivers/net/ethernet/intel/Kconfig                 |  216 ++++++++++++++=
++++++
>  drivers/net/ethernet/intel/Makefile                |   12 +
>  drivers/net/{ =3D> ethernet/intel}/e100.c            |    0
>  drivers/net/{ =3D> ethernet/intel}/e1000/Makefile    |    0
>  drivers/net/{ =3D> ethernet/intel}/e1000/e1000.h     |    0
>  .../net/{ =3D> ethernet/intel}/e1000/e1000_ethtool.c |    0
>  drivers/net/{ =3D> ethernet/intel}/e1000/e1000_hw.c  |    0
>  drivers/net/{ =3D> ethernet/intel}/e1000/e1000_hw.h  |    0
>  .../net/{ =3D> ethernet/intel}/e1000/e1000_main.c    |    0
>  .../net/{ =3D> ethernet/intel}/e1000/e1000_osdep.h   |    0
>  .../net/{ =3D> ethernet/intel}/e1000/e1000_param.c   |    0
>  .../intel/e1000e/80003es2lan.c}                    |    0
>  drivers/net/{ =3D> ethernet/intel}/e1000e/82571.c    |    0
>  drivers/net/{ =3D> ethernet/intel}/e1000e/Makefile   |    2 +-
>  drivers/net/{ =3D> ethernet/intel}/e1000e/defines.h  |    0
>  drivers/net/{ =3D> ethernet/intel}/e1000e/e1000.h    |    0
>  drivers/net/{ =3D> ethernet/intel}/e1000e/ethtool.c  |    0
>  drivers/net/{ =3D> ethernet/intel}/e1000e/hw.h       |    0
>  drivers/net/{ =3D> ethernet/intel}/e1000e/ich8lan.c  |    0
>  drivers/net/{ =3D> ethernet/intel}/e1000e/lib.c      |    0
>  drivers/net/{ =3D> ethernet/intel}/e1000e/netdev.c   |    0
>  drivers/net/{ =3D> ethernet/intel}/e1000e/param.c    |    0
>  drivers/net/{ =3D> ethernet/intel}/e1000e/phy.c      |    0
>  drivers/net/{ =3D> ethernet/intel}/igb/Makefile      |    0
>  drivers/net/{ =3D> ethernet/intel}/igb/e1000_82575.c |    0
>  drivers/net/{ =3D> ethernet/intel}/igb/e1000_82575.h |    0
>  .../net/{ =3D> ethernet/intel}/igb/e1000_defines.h   |    0
>  drivers/net/{ =3D> ethernet/intel}/igb/e1000_hw.h    |    0
>  drivers/net/{ =3D> ethernet/intel}/igb/e1000_mac.c   |    0
>  drivers/net/{ =3D> ethernet/intel}/igb/e1000_mac.h   |    0
>  drivers/net/{ =3D> ethernet/intel}/igb/e1000_mbx.c   |    0
>  drivers/net/{ =3D> ethernet/intel}/igb/e1000_mbx.h   |    0
>  drivers/net/{ =3D> ethernet/intel}/igb/e1000_nvm.c   |    0
>  drivers/net/{ =3D> ethernet/intel}/igb/e1000_nvm.h   |    0
>  drivers/net/{ =3D> ethernet/intel}/igb/e1000_phy.c   |    0
>  drivers/net/{ =3D> ethernet/intel}/igb/e1000_phy.h   |    0
>  drivers/net/{ =3D> ethernet/intel}/igb/e1000_regs.h  |    0
>  drivers/net/{ =3D> ethernet/intel}/igb/igb.h         |    0
>  drivers/net/{ =3D> ethernet/intel}/igb/igb_ethtool.c |    0
>  drivers/net/{ =3D> ethernet/intel}/igb/igb_main.c    |    0
>  drivers/net/{ =3D> ethernet/intel}/igbvf/Makefile    |    0
>  drivers/net/{ =3D> ethernet/intel}/igbvf/defines.h   |    0
>  drivers/net/{ =3D> ethernet/intel}/igbvf/ethtool.c   |    0
>  drivers/net/{ =3D> ethernet/intel}/igbvf/igbvf.h     |    0
>  drivers/net/{ =3D> ethernet/intel}/igbvf/mbx.c       |    0
>  drivers/net/{ =3D> ethernet/intel}/igbvf/mbx.h       |    0
>  drivers/net/{ =3D> ethernet/intel}/igbvf/netdev.c    |    0
>  drivers/net/{ =3D> ethernet/intel}/igbvf/regs.h      |    0
>  drivers/net/{ =3D> ethernet/intel}/igbvf/vf.c        |    0
>  drivers/net/{ =3D> ethernet/intel}/igbvf/vf.h        |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgb/Makefile     |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgb/ixgb.h       |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgb/ixgb_ee.c    |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgb/ixgb_ee.h    |    0
>  .../net/{ =3D> ethernet/intel}/ixgb/ixgb_ethtool.c   |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgb/ixgb_hw.c    |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgb/ixgb_hw.h    |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgb/ixgb_ids.h   |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgb/ixgb_main.c  |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgb/ixgb_osdep.h |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgb/ixgb_param.c |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgbe/Makefile    |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgbe/ixgbe.h     |    0
>  .../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_82598.c   |    0
>  .../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_82599.c   |    0
>  .../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_common.c  |    0
>  .../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_common.h  |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgbe/ixgbe_dcb.c |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgbe/ixgbe_dcb.h |    0
>  .../{ =3D> ethernet/intel}/ixgbe/ixgbe_dcb_82598.c   |    0
>  .../{ =3D> ethernet/intel}/ixgbe/ixgbe_dcb_82598.h   |    0
>  .../{ =3D> ethernet/intel}/ixgbe/ixgbe_dcb_82599.c   |    0
>  .../{ =3D> ethernet/intel}/ixgbe/ixgbe_dcb_82599.h   |    0
>  .../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_dcb_nl.c  |    0
>  .../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_ethtool.c |    0
>  .../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_fcoe.c    |    0
>  .../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_fcoe.h    |    0
>  .../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_main.c    |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgbe/ixgbe_mbx.c |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgbe/ixgbe_mbx.h |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgbe/ixgbe_phy.c |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgbe/ixgbe_phy.h |    0
>  .../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_sriov.c   |    0
>  .../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_sriov.h   |    0
>  .../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_type.h    |    0
>  .../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_x540.c    |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgbevf/Makefile  |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgbevf/defines.h |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgbevf/ethtool.c |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgbevf/ixgbevf.h |    0
>  .../{ =3D> ethernet/intel}/ixgbevf/ixgbevf_main.c    |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgbevf/mbx.c     |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgbevf/mbx.h     |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgbevf/regs.h    |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgbevf/vf.c      |    0
>  drivers/net/{ =3D> ethernet/intel}/ixgbevf/vf.h      |    0
>  101 files changed, 233 insertions(+), 218 deletions(-)
>=20
> commit e9518ae90966c061c0efa161e885ba23bda6c0a8
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Thu Apr 7 06:57:17 2011 -0700
>=20
>     chelsio: Move the Chelsio drivers
>=20
>     Moves the drivers for the Chelsio chipsets into
>     drivers/net/ethernet/chelsio/ and the necessary Kconfig and Makefile
>     changes.
>=20
>     CC: Divy Le Ray <divy@chelsio.com>
>     CC: Dimitris Michailidis <dm@chelsio.com>
>     CC: Casey Leedom <leedom@chelsio.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                        |    6 +-
>  drivers/net/Kconfig                                |   86 --------------=
--
>  drivers/net/Makefile                               |    4 -
>  drivers/net/ethernet/Kconfig                       |    1 +
>  drivers/net/ethernet/Makefile                      |    1 +
>  drivers/net/ethernet/chelsio/Kconfig               |  102 ++++++++++++++=
++++++
>  drivers/net/ethernet/chelsio/Makefile              |    8 ++
>  .../{chelsio =3D> ethernet/chelsio/cxgb}/Makefile    |    0
>  .../{chelsio =3D> ethernet/chelsio/cxgb}/common.h    |    0
>  .../net/{chelsio =3D> ethernet/chelsio/cxgb}/cphy.h  |    0
>  .../{chelsio =3D> ethernet/chelsio/cxgb}/cpl5_cmd.h  |    0
>  .../net/{chelsio =3D> ethernet/chelsio/cxgb}/cxgb2.c |    0
>  .../{chelsio =3D> ethernet/chelsio/cxgb}/elmer0.h    |    0
>  .../net/{chelsio =3D> ethernet/chelsio/cxgb}/espi.c  |    0
>  .../net/{chelsio =3D> ethernet/chelsio/cxgb}/espi.h  |    0
>  .../{chelsio =3D> ethernet/chelsio/cxgb}/fpga_defs.h |    0
>  .../net/{chelsio =3D> ethernet/chelsio/cxgb}/gmac.h  |    0
>  .../{chelsio =3D> ethernet/chelsio/cxgb}/mv88e1xxx.c |    0
>  .../{chelsio =3D> ethernet/chelsio/cxgb}/mv88e1xxx.h |    0
>  .../{chelsio =3D> ethernet/chelsio/cxgb}/mv88x201x.c |    0
>  .../{chelsio =3D> ethernet/chelsio/cxgb}/my3126.c    |    0
>  .../{chelsio =3D> ethernet/chelsio/cxgb}/pm3393.c    |    0
>  .../net/{chelsio =3D> ethernet/chelsio/cxgb}/regs.h  |    0
>  .../net/{chelsio =3D> ethernet/chelsio/cxgb}/sge.c   |    0
>  .../net/{chelsio =3D> ethernet/chelsio/cxgb}/sge.h   |    0
>  .../net/{chelsio =3D> ethernet/chelsio/cxgb}/subr.c  |    0
>  .../chelsio/cxgb}/suni1x10gexp_regs.h              |    0
>  .../net/{chelsio =3D> ethernet/chelsio/cxgb}/tp.c    |    0
>  .../net/{chelsio =3D> ethernet/chelsio/cxgb}/tp.h    |    0
>  .../{chelsio =3D> ethernet/chelsio/cxgb}/vsc7326.c   |    0
>  .../chelsio/cxgb}/vsc7326_reg.h                    |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb3/Makefile  |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb3/adapter.h |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb3/ael1002.c |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb3/aq100x.c  |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb3/common.h  |    0
>  .../{ =3D> ethernet/chelsio}/cxgb3/cxgb3_ctl_defs.h  |    0
>  .../net/{ =3D> ethernet/chelsio}/cxgb3/cxgb3_defs.h  |    0
>  .../net/{ =3D> ethernet/chelsio}/cxgb3/cxgb3_ioctl.h |    0
>  .../net/{ =3D> ethernet/chelsio}/cxgb3/cxgb3_main.c  |    0
>  .../{ =3D> ethernet/chelsio}/cxgb3/cxgb3_offload.c   |    0
>  .../{ =3D> ethernet/chelsio}/cxgb3/cxgb3_offload.h   |    0
>  .../chelsio}/cxgb3/firmware_exports.h              |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb3/l2t.c     |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb3/l2t.h     |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb3/mc5.c     |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb3/regs.h    |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb3/sge.c     |    0
>  .../net/{ =3D> ethernet/chelsio}/cxgb3/sge_defs.h    |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb3/t3_cpl.h  |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb3/t3_hw.c   |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb3/t3cdev.h  |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb3/version.h |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb3/vsc8211.c |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb3/xgmac.c   |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb4/Makefile  |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb4/cxgb4.h   |    0
>  .../net/{ =3D> ethernet/chelsio}/cxgb4/cxgb4_main.c  |    0
>  .../net/{ =3D> ethernet/chelsio}/cxgb4/cxgb4_uld.h   |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb4/l2t.c     |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb4/l2t.h     |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb4/sge.c     |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb4/t4_hw.c   |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb4/t4_hw.h   |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb4/t4_msg.h  |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb4/t4_regs.h |    0
>  .../net/{ =3D> ethernet/chelsio}/cxgb4/t4fw_api.h    |    0
>  .../net/{ =3D> ethernet/chelsio}/cxgb4vf/Makefile    |    0
>  .../net/{ =3D> ethernet/chelsio}/cxgb4vf/adapter.h   |    0
>  .../{ =3D> ethernet/chelsio}/cxgb4vf/cxgb4vf_main.c  |    0
>  drivers/net/{ =3D> ethernet/chelsio}/cxgb4vf/sge.c   |    0
>  .../{ =3D> ethernet/chelsio}/cxgb4vf/t4vf_common.h   |    0
>  .../net/{ =3D> ethernet/chelsio}/cxgb4vf/t4vf_defs.h |    0
>  .../net/{ =3D> ethernet/chelsio}/cxgb4vf/t4vf_hw.c   |    0
>  74 files changed, 115 insertions(+), 93 deletions(-)
>=20
> commit 1e954aa058cd1496b47b914878509e9ecf136d05
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Thu Apr 7 06:03:04 2011 -0700
>=20
>     broadcom: Move the Broadcom drivers
>=20
>     Moves the drivers for Broadcom devices into
>     drivers/net/ethernet/broadcom/ and the necessary Kconfig and Makefile
>     changes.
>=20
>     CC: Eilon Greenstein <eilong@broadcom.com>
>     CC: Michael Chan <mchan@broadcom.com>
>     CC: Matt Carlson <mcarlson@broadcom.com>
>     CC: Gary Zambrano <zambrano@broadcom.com>
>     CC: "Maciej W. Rozycki" <macro@linux-mips.org>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                        |   10 +-
>  drivers/net/Kconfig                                |   99 --------------=
---
>  drivers/net/Makefile                               |    7 --
>  drivers/net/ethernet/Kconfig                       |    1 +
>  drivers/net/ethernet/Makefile                      |    1 +
>  drivers/net/ethernet/broadcom/Kconfig              |  114 ++++++++++++++=
++++++
>  drivers/net/ethernet/broadcom/Makefile             |   11 ++
>  drivers/net/{ =3D> ethernet/broadcom}/b44.c          |    0
>  drivers/net/{ =3D> ethernet/broadcom}/b44.h          |    0
>  drivers/net/{ =3D> ethernet/broadcom}/bcm63xx_enet.c |    0
>  drivers/net/{ =3D> ethernet/broadcom}/bcm63xx_enet.h |    0
>  drivers/net/{ =3D> ethernet/broadcom}/bnx2.c         |    0
>  drivers/net/{ =3D> ethernet/broadcom}/bnx2.h         |    0
>  drivers/net/{ =3D> ethernet/broadcom}/bnx2_fw.h      |    0
>  drivers/net/{ =3D> ethernet/broadcom}/bnx2x/Makefile |    0
>  drivers/net/{ =3D> ethernet/broadcom}/bnx2x/bnx2x.h  |    0
>  .../net/{ =3D> ethernet/broadcom}/bnx2x/bnx2x_cmn.c  |    0
>  .../net/{ =3D> ethernet/broadcom}/bnx2x/bnx2x_cmn.h  |    0
>  .../net/{ =3D> ethernet/broadcom}/bnx2x/bnx2x_dcb.c  |    0
>  .../net/{ =3D> ethernet/broadcom}/bnx2x/bnx2x_dcb.h  |    0
>  .../net/{ =3D> ethernet/broadcom}/bnx2x/bnx2x_dump.h |    0
>  .../{ =3D> ethernet/broadcom}/bnx2x/bnx2x_ethtool.c  |    0
>  .../{ =3D> ethernet/broadcom}/bnx2x/bnx2x_fw_defs.h  |    0
>  .../broadcom}/bnx2x/bnx2x_fw_file_hdr.h            |    0
>  .../net/{ =3D> ethernet/broadcom}/bnx2x/bnx2x_hsi.h  |    0
>  .../net/{ =3D> ethernet/broadcom}/bnx2x/bnx2x_init.h |    0
>  .../{ =3D> ethernet/broadcom}/bnx2x/bnx2x_init_ops.h |    0
>  .../net/{ =3D> ethernet/broadcom}/bnx2x/bnx2x_link.c |    0
>  .../net/{ =3D> ethernet/broadcom}/bnx2x/bnx2x_link.h |    0
>  .../net/{ =3D> ethernet/broadcom}/bnx2x/bnx2x_main.c |    0
>  .../net/{ =3D> ethernet/broadcom}/bnx2x/bnx2x_reg.h  |    0
>  .../{ =3D> ethernet/broadcom}/bnx2x/bnx2x_stats.c    |    0
>  .../{ =3D> ethernet/broadcom}/bnx2x/bnx2x_stats.h    |    0
>  drivers/net/{ =3D> ethernet/broadcom}/cnic.c         |    4 +-
>  drivers/net/{ =3D> ethernet/broadcom}/cnic.h         |    0
>  drivers/net/{ =3D> ethernet/broadcom}/cnic_defs.h    |    0
>  drivers/net/{ =3D> ethernet/broadcom}/cnic_if.h      |    0
>  drivers/net/{ =3D> ethernet/broadcom}/sb1250-mac.c   |    0
>  drivers/net/{ =3D> ethernet/broadcom}/tg3.c          |    0
>  drivers/net/{ =3D> ethernet/broadcom}/tg3.h          |    0
>  40 files changed, 134 insertions(+), 113 deletions(-)
>=20
> commit 29072561a23c3802112a94fa0a9383773056f19a
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Sat Apr 2 06:20:12 2011 -0700
>=20
>     8390: Move the 8390 related drivers
>=20
>     Moves the drivers for the National Semi-conductor 8390 chipset into
>     drivers/net/ethernet/8390/ and the necessary Kconfig and Makefile
>     changes.
>=20
>     CC: Donald Becker <becker@scyld.com>
>     CC: Paul Gortmaker <paul.gortmaker@windriver.com>
>     CC: Alain Malek <alain.malek@cryogen.com>
>     CC: Peter De Schrijver <p2@mind.be>
>     CC: "David Huggins-Daines" <dhd@debian.org>
>     CC: Wim Dumon <wimpie@kotnet.org>
>     CC: Yoshinori Sato <ysato@users.sourceforge.jp>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                                   |    5 +-
>  drivers/net/Kconfig                           |  283 -------------------=
----
>  drivers/net/Makefile                          |   22 --
>  drivers/net/ethernet/3com/Makefile            |    2 +-
>  drivers/net/{ =3D> ethernet/8390}/8390.c        |    0
>  drivers/net/{ =3D> ethernet/8390}/8390.h        |    0
>  drivers/net/{ =3D> ethernet/8390}/8390p.c       |    0
>  drivers/net/ethernet/8390/Kconfig             |  301 +++++++++++++++++++=
++++++
>  drivers/net/ethernet/8390/Makefile            |   26 +++
>  drivers/net/{ =3D> ethernet/8390}/ac3200.c      |    0
>  drivers/net/{ =3D> ethernet/8390}/apne.c        |    0
>  drivers/net/{ =3D> ethernet/8390}/ax88796.c     |    0
>  drivers/net/{ =3D> ethernet/8390}/e2100.c       |    0
>  drivers/net/{ =3D> ethernet/8390}/es3210.c      |    0
>  drivers/net/{ =3D> ethernet/8390}/hp-plus.c     |    0
>  drivers/net/{ =3D> ethernet/8390}/hp.c          |    0
>  drivers/net/{ =3D> ethernet/8390}/hydra.c       |    0
>  drivers/net/{ =3D> ethernet/8390}/lib8390.c     |    0
>  drivers/net/{ =3D> ethernet/8390}/lne390.c      |    0
>  drivers/net/{ =3D> ethernet/8390}/mac8390.c     |    0
>  drivers/net/{ =3D> ethernet/8390}/ne-h8300.c    |    0
>  drivers/net/{ =3D> ethernet/8390}/ne.c          |    0
>  drivers/net/{ =3D> ethernet/8390}/ne2k-pci.c    |    0
>  drivers/net/{ =3D> ethernet/8390}/ne3210.c      |    0
>  drivers/net/{ =3D> ethernet/8390}/smc-mca.c     |    0
>  drivers/net/{ =3D> ethernet/8390}/smc-ultra.c   |    0
>  drivers/net/{ =3D> ethernet/8390}/smc-ultra32.c |    0
>  drivers/net/{ =3D> ethernet/8390}/stnic.c       |    0
>  drivers/net/{ =3D> ethernet/8390}/wd.c          |    0
>  drivers/net/{ =3D> ethernet/8390}/zorro8390.c   |    0
>  drivers/net/ethernet/Kconfig                  |    1 +
>  drivers/net/ethernet/Makefile                 |    1 +
>  32 files changed, 332 insertions(+), 309 deletions(-)
>=20
> commit 6b9ef2886e37d62018cd72dcdd2918e9fb982aed
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Wed Mar 30 07:46:36 2011 -0700
>=20
>     amd8111e/pcnet32/*lance/mvme147: Move AMD chipset drivers
>=20
>     Moves the drivers for the AMD chipsets into drivers/net/ethernet/amd/
>     and the necessary Kconfig and Makfile changes.
>=20
>     CC: Peter Maydell <pmaydell@chiark.greenend.org.uk>
>     CC: Roman Hodek <Roman.Hodek@informatik.uni-erlangen.de>
>     CC: "Maciej W. Rozycki" <macro@linux-mips.org>
>     CC: Donald Becker <becker@scyld.com>
>     CC: Sam Creasey <sammy@users.qual.net>
>     CC: Miguel de Icaza <miguel@nuclecu.unam.mx>
>     CC: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  drivers/net/Kconfig                         |   99 ---------------------=
--
>  drivers/net/Makefile                        |    9 --
>  drivers/net/ethernet/Kconfig                |    1 +
>  drivers/net/ethernet/Makefile               |    1 +
>  drivers/net/{ =3D> ethernet/amd}/7990.c       |    0
>  drivers/net/{ =3D> ethernet/amd}/7990.h       |    0
>  drivers/net/ethernet/amd/Kconfig            |  115 +++++++++++++++++++++=
++++++
>  drivers/net/ethernet/amd/Makefile           |   13 +++
>  drivers/net/{ =3D> ethernet/amd}/amd8111e.c   |    0
>  drivers/net/{ =3D> ethernet/amd}/amd8111e.h   |    0
>  drivers/net/{ =3D> ethernet/amd}/atarilance.c |    0
>  drivers/net/{ =3D> ethernet/amd}/declance.c   |    0
>  drivers/net/{ =3D> ethernet/amd}/hplance.c    |    0
>  drivers/net/{ =3D> ethernet/amd}/hplance.h    |    0
>  drivers/net/{ =3D> ethernet/amd}/lance.c      |    0
>  drivers/net/{ =3D> ethernet/amd}/mvme147.c    |    0
>  drivers/net/{ =3D> ethernet/amd}/pcnet32.c    |    0
>  drivers/net/{ =3D> ethernet/amd}/sun3lance.c  |    0
>  drivers/net/{ =3D> ethernet/amd}/sunlance.c   |    0
>  19 files changed, 130 insertions(+), 108 deletions(-)
>=20
> commit b2ee2cf62d14c842272db622d6be6374bc6d622a
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Wed Mar 30 03:47:06 2011 -0700
>=20
>     3c*/acenic/typhoon: Move 3Com Ethernet drivers
>=20
>     Moves the 3Com drivers into drivers/net/ethernet/3com/ and the necess=
ary
>     Kconfig and Makefile changes.
>=20
>     CC: Philip Blundell <philb@gnu.org>
>     CC: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
>     CC: David Dillow <dave@thedillows.org>
>     CC: Jes Sorensen <jes@trained-monkey.org>
>     CC: Alan Cox <alan@linux.intel.com>
>     CC: Donald Becker <becker@scyld.com>
>     CC: Craig Southeren <craigs@ineluki.apana.org.au>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  MAINTAINERS                               |    8 +-
>  drivers/net/Kconfig                       |  177 -----------------------=
-----
>  drivers/net/Makefile                      |   12 +--
>  drivers/net/{ =3D> ethernet/3com}/3c501.c   |    0
>  drivers/net/{ =3D> ethernet/3com}/3c501.h   |    0
>  drivers/net/{ =3D> ethernet/3com}/3c503.c   |    0
>  drivers/net/{ =3D> ethernet/3com}/3c503.h   |    0
>  drivers/net/{ =3D> ethernet/3com}/3c505.c   |    0
>  drivers/net/{ =3D> ethernet/3com}/3c505.h   |    0
>  drivers/net/{ =3D> ethernet/3com}/3c507.c   |    0
>  drivers/net/{ =3D> ethernet/3com}/3c509.c   |    0
>  drivers/net/{ =3D> ethernet/3com}/3c515.c   |    0
>  drivers/net/{ =3D> ethernet/3com}/3c523.c   |    0
>  drivers/net/{ =3D> ethernet/3com}/3c523.h   |    0
>  drivers/net/{ =3D> ethernet/3com}/3c527.c   |    0
>  drivers/net/{ =3D> ethernet/3com}/3c527.h   |    0
>  drivers/net/{ =3D> ethernet/3com}/3c59x.c   |    0
>  drivers/net/ethernet/3com/Kconfig         |  180 +++++++++++++++++++++++=
++++++
>  drivers/net/ethernet/3com/Makefile        |   15 +++
>  drivers/net/{ =3D> ethernet/3com}/acenic.c  |    0
>  drivers/net/{ =3D> ethernet/3com}/acenic.h  |    0
>  drivers/net/{ =3D> ethernet/3com}/typhoon.c |    0
>  drivers/net/{ =3D> ethernet/3com}/typhoon.h |    0
>  drivers/net/ethernet/Kconfig              |    2 +
>  drivers/net/ethernet/Makefile             |    1 +
>  25 files changed, 203 insertions(+), 192 deletions(-)
>=20
> commit b918e3bb62b873c5436d413b99f593b3eed78901
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Tue Mar 29 18:25:21 2011 -0700
>=20
>     drivers/net/ethernet: Add ethernet dir and config option
>=20
>     This is the initial patch to organize the drivers/net directory
>     structure and networking device driver config options.  This patch
>     does the following:
>       - add drivers/net/ethernet/Kconfig
>       - integrate the new files into the existing config
>=20
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
>  drivers/net/Kconfig           |    2 ++
>  drivers/net/Makefile          |    2 +-
>  drivers/net/ethernet/Kconfig  |   14 ++++++++++++++
>  drivers/net/ethernet/Makefile |    4 ++++
>  4 files changed, 21 insertions(+), 1 deletions(-)
>=20
>=20
>=20



--=-7RG3bV9ETdMO0TSJjaAE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJN/q+ZAAoJECTsCADr/EWUMzMH/1lqaoY6z57J355VQmqAeSiI
4bzzGU/2XQEVPx8+CBLxEpKHPSEmMLQjTfhBAwH66EL3tGKekf928cx7b+CuJDm/
WRUVdxgoaitx2L+z+CN8xP0un7XQ+CYVfVXVw0VBeFz1N0nogYhEfroANVsgBg5H
tI400dJ1iIctW37Izd5msgNA/AikwO8JYsQ0W0c5GncENlfa4Z3NHh/WCus0nUFG
yEhFW5OJKjmfWX++5SUWXbOLNFcpSYLRklNpdTx0vv0cw2nG55Q8MNVBAmfbV+gl
My5COoK3rJqZRvGu3Idkc/D/LzCna9QQxOWUC4XLAUH2LQlhNy5GrqzrkSrqpyE=
=9/bR
-----END PGP SIGNATURE-----

--=-7RG3bV9ETdMO0TSJjaAE--

