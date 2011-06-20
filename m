From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC] Moving files around in drivers/net
Date: Sun, 19 Jun 2011 18:59:33 -0700
Message-ID: <1308535174.22851.26.camel@jtkirshe-mobl>
References: <1306956602.32125.28.camel@Joe-Laptop>
	 <1306957998.3076.18.camel@jtkirshe-MOBL1>
	 <1306958478.32125.32.camel@Joe-Laptop>
	 <BANLkTi=BAqKzZeLF2_uCYnr7PD3StGFgAg@mail.gmail.com>
	 <1308186619.12377.23.camel@Joe-Laptop>
	 <BANLkTin0QzAscKcN0Yw6rc7fUh5d5q143w@mail.gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-/kGUdYv4PxPCRwQJlT4n"
Cc: Joe Perches <joe@perches.com>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Andrew Gallatin <gallatin@myri.com>
To: Jon Mason <jon.mason@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44552 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750731Ab1FTB7p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jun 2011 21:59:45 -0400
In-Reply-To: <BANLkTin0QzAscKcN0Yw6rc7fUh5d5q143w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-/kGUdYv4PxPCRwQJlT4n
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-06-16 at 08:03 -0700, Jon Mason wrote:
> On Wed, Jun 15, 2011 at 8:10 PM, Joe Perches <joe@perches.com> wrote:
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
> >> >> I am over 90% done with the work and have been trying to finish
> up the
> >> >> patches so that I could get them out as an RFC here in the next
> week.
> >> > Excellent, thanks.
> >> I thought for sure I would have finished what I have left by last
> >> weekend, but I keep getting interrupted.  (Blame it on the NHL
> stanley
> >> cup playoffs) :)
> >> I have created a git tree on kernel.org with all the work that I
> have
> >> completed so far (see below).  This first stage of the move is only
> >> taking care of the drivers.  The next stage will move the
> networking
> >> core drivers (bridging, bonding, vlan, etc.) into drivers/net/sw.
> >>
> git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-organize
> >> I will send out all the patches as an RFC by the end of the week
> (for sure)
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
> > $ git log --stat -M b7c7deeb4c77538577f0b6a724f10ce8693eb648..
> > commit 743b1f134daef72805cb10e74d82dcbb95cd2568
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Tue Jun 14 14:02:57 2011 -0700
> >
> >    hamachi/yellowfin: Move the packet engine drivers
> >
> >    Move the packet engine drivers to drivers/net/ethernet/pktgen/
> and
> >    the necessary Kconfig and Makefile changes.
> >
> >    CC: Donald Becker <becker@scyld.com>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  drivers/net/Kconfig                           |   26
> ---------------
> >  drivers/net/Makefile                          |    2 -
> >  drivers/net/ethernet/Kconfig                  |    1 +
> >  drivers/net/ethernet/Makefile                 |    1 +
> >  drivers/net/ethernet/pkteng/Kconfig           |   42
> +++++++++++++++++++++++++
> >  drivers/net/ethernet/pkteng/Makefile          |    6 +++
> >  drivers/net/{ =3D> ethernet/pkteng}/hamachi.c   |    0
> >  drivers/net/{ =3D> ethernet/pkteng}/yellowfin.c |    0
> >  8 files changed, 50 insertions(+), 28 deletions(-)
> >
> > commit a7ce0b86340574f90bd24c460c3495ae3e06f5fb
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Tue Jun 14 13:35:31 2011 -0700
> >
> >    ixp2000: Move the Radisys driver
> >
> >    Move the Radisys driver into drivers/net/ethernet/ixp2000/ and
> >    make the necessary Kconfig and Makefile changes
> >
> >    CC: Lennert Buytenhek <kernel@wantstofly.org>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  MAINTAINERS                                        |    2 +-
> >  drivers/net/Kconfig                                |    2 --
> >  drivers/net/Makefile                               |    1 -
> >  drivers/net/ethernet/Kconfig                       |    1 +
> >  drivers/net/ethernet/Makefile                      |    1 +
> >  drivers/net/{ =3D> ethernet}/ixp2000/Kconfig         |    0
> >  drivers/net/{ =3D> ethernet}/ixp2000/Makefile        |    0
> >  drivers/net/{ =3D> ethernet}/ixp2000/caleb.c         |    0
> >  drivers/net/{ =3D> ethernet}/ixp2000/caleb.h         |    0
> >  drivers/net/{ =3D> ethernet}/ixp2000/enp2611.c       |    0
> >  drivers/net/{ =3D> ethernet}/ixp2000/ixp2400-msf.c   |    0
> >  drivers/net/{ =3D> ethernet}/ixp2000/ixp2400-msf.h   |    0
> >  drivers/net/{ =3D> ethernet}/ixp2000/ixp2400_rx.uc   |    0
> >  .../net/{ =3D> ethernet}/ixp2000/ixp2400_rx.ucode    |    0
> >  drivers/net/{ =3D> ethernet}/ixp2000/ixp2400_tx.uc   |    0
> >  .../net/{ =3D> ethernet}/ixp2000/ixp2400_tx.ucode    |    0
> >  drivers/net/{ =3D> ethernet}/ixp2000/ixpdev.c        |    0
> >  drivers/net/{ =3D> ethernet}/ixp2000/ixpdev.h        |    0
> >  drivers/net/{ =3D> ethernet}/ixp2000/ixpdev_priv.h   |    0
> >  drivers/net/{ =3D> ethernet}/ixp2000/pm3386.c        |    0
> >  drivers/net/{ =3D> ethernet}/ixp2000/pm3386.h        |    0
> >  21 files changed, 3 insertions(+), 4 deletions(-)
> >
> > commit 73091715bc0690f82ef9489f3589ad9b2d747cc0
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Tue Jun 14 12:56:50 2011 -0700
> >
> >    tlan/cpmac: Move the TI drivers
> >
> >    Move the TI drivers to drivers/net/ethernet/ti/ and make the
> >    necessary Kconfig and Makefile changes.
> >
> >    CC: Samuel Chessman <chessman@tux.org>
> >    CC: <torben.mathiasen@compaq.com>
> >    CC: Eugene Konev <ejka@imfi.kspu.ru>
> >    CC: Florian Fainelli <florian@openwrt.org>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  MAINTAINERS                           |    4 +-
> >  drivers/net/Kconfig                   |   25 --------------------
> >  drivers/net/Makefile                  |    2 -
> >  drivers/net/ethernet/Kconfig          |    1 +
> >  drivers/net/ethernet/Makefile         |    1 +
> >  drivers/net/ethernet/ti/Kconfig       |   41
> +++++++++++++++++++++++++++++++++
> >  drivers/net/ethernet/ti/Makefile      |    6 +++++
> >  drivers/net/{ =3D> ethernet/ti}/cpmac.c |    0
> >  drivers/net/{ =3D> ethernet/ti}/tlan.c  |    0
> >  drivers/net/{ =3D> ethernet/ti}/tlan.h  |    0
> >  10 files changed, 51 insertions(+), 29 deletions(-)
> >
> > commit 035a452c66dbc0aa7873a12cfe057c74eaf89111
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Mon Jun 13 10:51:34 2011 -0700
> >
> >    s6gmac/tsi108_eth: Move the s6gmac/tsi108_eth drivers
> >
> >    Move the s6gmac/tsi108_eth drivers to drivers/net/ethernet/ and
> >    make the necessary Kconfig and Makefile changes.
> >
> >    CC: Oskar Schirmer <os@emlix.com>
> >    CC: Kong Lai <kong.lai@tundra.com>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  drivers/net/Kconfig                     |   19 -------------------
> >  drivers/net/Makefile                    |    2 --
> >  drivers/net/ethernet/Kconfig            |   21
> +++++++++++++++++++++
> >  drivers/net/ethernet/Makefile           |    2 ++
> >  drivers/net/{ =3D> ethernet}/s6gmac.c     |    0
> >  drivers/net/{ =3D> ethernet}/tsi108_eth.c |    0
> >  drivers/net/{ =3D> ethernet}/tsi108_eth.h |    0
> >  7 files changed, 23 insertions(+), 21 deletions(-)
> >
> > commit 4f9d3b9af95ced49b9ad9d5fb222f5216bf0adbb
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Mon Jun 13 10:03:01 2011 -0700
> >
> >    a2065/ariadne: Move the a2065/ariadne drivers
> >
> >    Move the a2065/ariadne drivers to drivers/net/ethernet/ and make
> >    the necessary Kconfig and Makefile changes.
> >
> >    CC: Geert Uytterhoeven <geert@linux-m68k.org>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  drivers/net/Kconfig                  |   21 ---------------------
> >  drivers/net/Makefile                 |    2 --
> >  drivers/net/ethernet/Kconfig         |   23 +++++++++++++++++++++++
> >  drivers/net/ethernet/Makefile        |    2 ++
> >  drivers/net/{ =3D> ethernet}/a2065.c   |    0
> >  drivers/net/{ =3D> ethernet}/a2065.h   |    0
> >  drivers/net/{ =3D> ethernet}/ariadne.c |    0
> >  drivers/net/{ =3D> ethernet}/ariadne.h |    0
> >  8 files changed, 25 insertions(+), 23 deletions(-)
> >
> > commit aead66521a701f08e3ae91aec7c9c8863a07a511
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Mon Jun 13 09:43:17 2011 -0700
> >
> >    82586.c/fec*: Move the Motorola drivers
> >
> >    Move the Motorola drivers into drivers/net/ethernet/motorola/ and
> >    make the necessary Kconfig and Makefile changes
> >
> >    CC: Dan Malek <dmalek@jlc.net>
> >    CC: Sylvain Munaut <tnt@246tNt.com>
> >    CC: Richard Hirst <richard@sleepie.demon.co.uk>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  drivers/net/Kconfig                                |   49
> --------------
> >  drivers/net/Makefile                               |    7 --
> >  drivers/net/ethernet/Kconfig                       |    1 +
> >  drivers/net/ethernet/Makefile                      |    1 +
> >  drivers/net/{ =3D> ethernet/motorola}/82596.c        |    0
> >  drivers/net/ethernet/motorola/Kconfig              |   68
> ++++++++++++++++++++
> >  drivers/net/ethernet/motorola/Makefile             |   11 +++
> >  drivers/net/{ =3D> ethernet/motorola}/fec.c          |    0
> >  drivers/net/{ =3D> ethernet/motorola}/fec.h          |    0
> >  drivers/net/{ =3D> ethernet/motorola}/fec_mpc52xx.c  |    0
> >  drivers/net/{ =3D> ethernet/motorola}/fec_mpc52xx.h  |    0
> >  .../net/{ =3D> ethernet/motorola}/fec_mpc52xx_phy.c  |    0
> >  12 files changed, 81 insertions(+), 56 deletions(-)
> >
> > commit aebcb70982c66b54605fbd242f6ac035b2e205b3
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Mon Jun 13 08:43:49 2011 -0700
> >
> >    sis*: Move the Silicon Integrated Systems (SiS) drivers
> >
> >    Move the SiS drivers into drivers/net/ethernet/sis/ and make the
> >    necessary Kconfig and Makefile changes
> >
> >    CC: Daniele Venzano <venza@brownhat.org>
> >    CC: Francois Romieu <romieu@fr.zoreil.com>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  MAINTAINERS                             |    4 +-
> >  drivers/net/Kconfig                     |   30 --------------------
> >  drivers/net/Makefile                    |    2 -
> >  drivers/net/ethernet/Kconfig            |    1 +
> >  drivers/net/ethernet/Makefile           |    1 +
> >  drivers/net/ethernet/sis/Kconfig        |   46
> +++++++++++++++++++++++++++++++
> >  drivers/net/ethernet/sis/Makefile       |    6 ++++
> >  drivers/net/{ =3D> ethernet/sis}/sis190.c |    0
> >  drivers/net/{ =3D> ethernet/sis}/sis900.c |    0
> >  drivers/net/{ =3D> ethernet/sis}/sis900.h |    0
> >  10 files changed, 56 insertions(+), 34 deletions(-)
> >
> > commit 826bef22759e1f78b284c9dc53ea442d348dbc88
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Mon Jun 13 08:23:31 2011 -0700
> >
> >    spider_net: Move the spider_net (IBM) driver
> >
> >    Move the spider_net (IBM) driver into drivers/net/ethernet/ibm/
> and
> >    make the necessary Kconfig and Makefile changes
> >
> >    CC: Utz Bacher <utz.bacher@de.ibm.com>
> >    CC: Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
> >    CC: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  MAINTAINERS                                        |    2 +-
> >  drivers/net/Kconfig                                |    8 --------
> >  drivers/net/Makefile                               |    2 --
> >  drivers/net/ethernet/ibm/Kconfig                   |   11
> ++++++++++-
> >  drivers/net/ethernet/ibm/Makefile                  |    2 ++
> >  drivers/net/{ =3D> ethernet/ibm}/spider_net.c        |    0
> >  drivers/net/{ =3D> ethernet/ibm}/spider_net.h        |    2 +-
> >  .../net/{ =3D> ethernet/ibm}/spider_net_ethtool.c    |    0
> >  8 files changed, 14 insertions(+), 13 deletions(-)
> >
> > commit 776fae874e79c3bf3b6fd81eceb23993fef76c01
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Mon Jun 13 07:56:34 2011 -0700
> >
> >    mv643xx/pxa168: Move the Marvell drivers
> >
> >    Move the Marvell drivers into driver/net/ethernet/marvell and
> make
> >    the necessary Kconfig and Makefile changes.
> >
> >    CC: Sachin Sanap <ssanap@marvell.com>
> >    CC: Zhangfei Gao <zgao6@marvell.com>
> >    CC: Philip Rakity <prakity@marvell.com>
> >    CC: Mark Brown <markb@marvell.com>
> >    CC: Lennert Buytenhek <buytenh@marvell.com>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  MAINTAINERS                                      |    2 +-
> >  drivers/net/Kconfig                              |   23
> ------------
> >  drivers/net/Makefile                             |    2 -
> >  drivers/net/ethernet/Kconfig                     |    1 +
> >  drivers/net/ethernet/Makefile                    |    1 +
> >  drivers/net/ethernet/marvell/Kconfig             |   40
> ++++++++++++++++++++++
> >  drivers/net/ethernet/marvell/Makefile            |    6 +++
> >  drivers/net/{ =3D> ethernet/marvell}/mv643xx_eth.c |    0
> >  drivers/net/{ =3D> ethernet/marvell}/pxa168_eth.c  |    0
> >  9 files changed, 49 insertions(+), 26 deletions(-)
> >
> > commit 4153aed9e3020693985219d471f8eb230a8eaefa
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Sat Jun 11 03:26:31 2011 -0700
> >
> >    ks8*/ksz8*: Move the Micrel drivers
> >
> >    Move the Micrel drivers into drivers/net/ethernet/micrel/ and
> >    make the necessary Kconfig and Makefile changes.
> >
> >    CC: Ben Dooks <ben@simtec.co.uk>
> >    CC: Tristram Ha <Tristram.Ha@micrel.com>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  drivers/net/Kconfig                            |   35
> ----------------
> >  drivers/net/Makefile                           |    4 --
> >  drivers/net/ethernet/Kconfig                   |    1 +
> >  drivers/net/ethernet/Makefile                  |    1 +
> >  drivers/net/ethernet/micrel/Kconfig            |   51
> ++++++++++++++++++++++++
> >  drivers/net/ethernet/micrel/Makefile           |    8 ++++
> >  drivers/net/{ =3D> ethernet/micrel}/ks8842.c     |    0
> >  drivers/net/{ =3D> ethernet/micrel}/ks8851.c     |    0
> >  drivers/net/{ =3D> ethernet/micrel}/ks8851.h     |    0
> >  drivers/net/{ =3D> ethernet/micrel}/ks8851_mll.c |    0
> >  drivers/net/{ =3D> ethernet/micrel}/ksz884x.c    |    0
> >  11 files changed, 61 insertions(+), 39 deletions(-)
> >
> > commit 518f5abc833cb0c30b79161c071b7c93ed458c6d
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Sat Jun 11 02:29:36 2011 -0700
> >
> >    fsl_*/gianfar*/ucc_*: Move the Freescale drivers
> >
> >    Move the Freescale driver into drivers/net/ethernet/freescale/
> and
> >    make the necessary Kconfig and Makefile changes.
> >
> >    CC: Sandeep Gopalpet <sandeep.kumar@freescale.com>
> >    CC: Andy Fleming <afleming@freescale.com>
> >    CC: Shlomi Gridish <gridish@freescale.com>
> >    CC: Li Yang <leoli@freescale.com>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  MAINTAINERS                                        |    2 +-
> >  drivers/net/Kconfig                                |   33
> -------------
> >  drivers/net/Makefile                               |   14 ------
> >  drivers/net/ethernet/Kconfig                       |    1 +
> >  drivers/net/ethernet/Makefile                      |    1 +
> >  drivers/net/ethernet/freescale/Kconfig             |   48
> ++++++++++++++++++++
> >  drivers/net/ethernet/freescale/Makefile            |   13 +++++
> >  .../net/{ =3D> ethernet/freescale}/fs_enet/Kconfig   |    2 +-
> >  .../net/{ =3D> ethernet/freescale}/fs_enet/Makefile  |    0
> >  drivers/net/{ =3D> ethernet/freescale}/fs_enet/fec.h |    0
> >  .../freescale}/fs_enet/fs_enet-main.c              |    0
> >  .../net/{ =3D> ethernet/freescale}/fs_enet/fs_enet.h |    0
> >  .../net/{ =3D> ethernet/freescale}/fs_enet/mac-fcc.c |    0
> >  .../net/{ =3D> ethernet/freescale}/fs_enet/mac-fec.c |    0
> >  .../net/{ =3D> ethernet/freescale}/fs_enet/mac-scc.c |    0
> >  .../{ =3D> ethernet/freescale}/fs_enet/mii-bitbang.c |    0
> >  .../net/{ =3D> ethernet/freescale}/fs_enet/mii-fec.c |    0
> >  drivers/net/{ =3D> ethernet/freescale}/fsl_pq_mdio.c |    0
> >  drivers/net/{ =3D> ethernet/freescale}/fsl_pq_mdio.h |    0
> >  drivers/net/{ =3D> ethernet/freescale}/gianfar.c     |    0
> >  drivers/net/{ =3D> ethernet/freescale}/gianfar.h     |    0
> >  .../net/{ =3D> ethernet/freescale}/gianfar_ethtool.c |    0
> >  drivers/net/{ =3D> ethernet/freescale}/gianfar_ptp.c |    0
> >  .../net/{ =3D> ethernet/freescale}/gianfar_sysfs.c   |    0
> >  drivers/net/{ =3D> ethernet/freescale}/ucc_geth.c    |    0
> >  drivers/net/{ =3D> ethernet/freescale}/ucc_geth.h    |    0
> >  .../{ =3D> ethernet/freescale}/ucc_geth_ethtool.c    |    0
> >  27 files changed, 65 insertions(+), 49 deletions(-)
> >
> > commit dbf507c912fcc804a20d86d2194fc4a4298f39df
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Sat Jun 11 01:13:22 2011 -0700
> >
> >    eepro/eexpress/eth16i/ewrk3/lp486e/seeq8005/znet: Move the ISA
> drivers
> >
> >    Move the ISA drivers into drivers/net/ethernet/isa/ and make the
> >    necessary Kconfig and Makefile changes.
> >
> >    CC: Philip Blundell <philb@gnu.org>
> >    CC: Mika Kuoppala <miku@iki.fi>
> >    CC: <bao.ha@srs.gov>
> >    CC: <aris@cathedrallabs.org>
> >    CC: David Davies <davies@maniac.ultranet.com>
> >    CC: <aeb@cwi.nl>
> >    CC: Hamish Coleman <hamish@zot.apana.org.au>
> >    CC: Donald Becker <becker@scyld.com>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  MAINTAINERS                               |    4 +-
> >  drivers/net/Kconfig                       |   98
> ----------------------------
> >  drivers/net/Makefile                      |   10 ---
> >  drivers/net/ethernet/Kconfig              |    1 +
> >  drivers/net/ethernet/Makefile             |    1 +
> >  drivers/net/ethernet/isa/Kconfig          |  101
> +++++++++++++++++++++++++++++
> >  drivers/net/ethernet/isa/Makefile         |   11 +++
> >  drivers/net/{ =3D> ethernet/isa}/eepro.c    |    0
> >  drivers/net/{ =3D> ethernet/isa}/eexpress.c |    0
> >  drivers/net/{ =3D> ethernet/isa}/eexpress.h |    0
> >  drivers/net/{ =3D> ethernet/isa}/eth16i.c   |    0
> >  drivers/net/{ =3D> ethernet/isa}/ewrk3.c    |    0
> >  drivers/net/{ =3D> ethernet/isa}/ewrk3.h    |    0
> >  drivers/net/{ =3D> ethernet/isa}/lp486e.c   |    0
> >  drivers/net/{ =3D> ethernet/isa}/seeq8005.c |    0
> >  drivers/net/{ =3D> ethernet/isa}/seeq8005.h |    0
> >  drivers/net/{ =3D> ethernet/isa}/znet.c     |    0
> >  17 files changed, 116 insertions(+), 110 deletions(-)
> >
> > commit b8a6199b8d692ae17932b8c8cc709898255a51ad
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Fri May 20 20:43:09 2011 -0700
> >
> >    via-*: Move the VIA drivers
> >
> >    Move the VIA drivers into drivers/net/ethernet/via/ and make the
> >    necessary Kconfig and Makefile changes.
> >
> >    CC: Roger Luethi <rl@hellgate.ch>
> >    CC: Francois Romieu <romieu@fr.zoreil.com>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  MAINTAINERS                                   |    4 +-
> >  drivers/net/Kconfig                           |   36
> -----------------
> >  drivers/net/Makefile                          |    2 -
> >  drivers/net/ethernet/Kconfig                  |    1 +
> >  drivers/net/ethernet/Makefile                 |    1 +
> >  drivers/net/ethernet/via/Kconfig              |   52
> +++++++++++++++++++++++++
> >  drivers/net/ethernet/via/Makefile             |    6 +++
> >  drivers/net/{ =3D> ethernet/via}/via-rhine.c    |    0
> >  drivers/net/{ =3D> ethernet/via}/via-velocity.c |    0
> >  drivers/net/{ =3D> ethernet/via}/via-velocity.h |    0
> >  10 files changed, 62 insertions(+), 40 deletions(-)
> >
> > commit 0cc82a49e423bc0b2ee19c49ad24376d1ffccdc5
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Fri May 20 20:18:55 2011 -0700
> >
> >    skge/sky2: Move the SysKonnect Ethernet drivers
> >
> >    Move the SysKonnect (Ethernet only) drivers into
> drivers/net/ethernet/syskonnect/
> >    and make the necessary Kconfig and Makefile changes.
> >
> >    CC: Stephen Hemminger <shemminger@linux-foundation.org>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  MAINTAINERS                                  |    3 +-
> >  drivers/net/Kconfig                          |   58
> --------------------
> >  drivers/net/Makefile                         |    2 -
> >  drivers/net/ethernet/Kconfig                 |    1 +
> >  drivers/net/ethernet/Makefile                |    1 +
> >  drivers/net/ethernet/syskonnect/Kconfig      |   74
> ++++++++++++++++++++++++++
> >  drivers/net/ethernet/syskonnect/Makefile     |    6 ++
> >  drivers/net/{ =3D> ethernet/syskonnect}/skge.c |    0
> >  drivers/net/{ =3D> ethernet/syskonnect}/skge.h |    0
> >  drivers/net/{ =3D> ethernet/syskonnect}/sky2.c |    0
> >  drivers/net/{ =3D> ethernet/syskonnect}/sky2.h |    0
> >  11 files changed, 83 insertions(+), 62 deletions(-)
> >
> > commit c9e8faa7214a8911a22281e6e688e0cc69bb54b8
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Fri May 20 19:48:55 2011 -0700
> >
> >    pch_gbe: Move the OKI driver
> >
> >    Move the OKI driver into driver/net/ethernet/pch_gbe/ and make
> the
> >    necessary Kconfig and Makefile changes.
> >
> >    Note: there is no documented maintainer for this driver, so I
> CC'd
> >    the last 2 major contributors.
> >
> >    CC: Tomoya <tomoya-linux@dsn.okisemi.com>
> >    CC: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  drivers/net/Kconfig                                |   19
> -------------------
> >  drivers/net/Makefile                               |    1 -
> >  drivers/net/ethernet/Kconfig                       |    1 +
> >  drivers/net/ethernet/Makefile                      |    1 +
> >  drivers/net/ethernet/pch_gbe/Kconfig               |   20
> ++++++++++++++++++++
> >  drivers/net/{ =3D> ethernet}/pch_gbe/Makefile        |    0
> >  drivers/net/{ =3D> ethernet}/pch_gbe/pch_gbe.h       |    0
> >  drivers/net/{ =3D> ethernet}/pch_gbe/pch_gbe_api.c   |    0
> >  drivers/net/{ =3D> ethernet}/pch_gbe/pch_gbe_api.h   |    0
> >  .../net/{ =3D> ethernet}/pch_gbe/pch_gbe_ethtool.c   |    0
> >  drivers/net/{ =3D> ethernet}/pch_gbe/pch_gbe_main.c  |    0
> >  drivers/net/{ =3D> ethernet}/pch_gbe/pch_gbe_param.c |    0
> >  drivers/net/{ =3D> ethernet}/pch_gbe/pch_gbe_phy.c   |    0
> >  drivers/net/{ =3D> ethernet}/pch_gbe/pch_gbe_phy.h   |    0
> >  14 files changed, 22 insertions(+), 20 deletions(-)
> >
> > commit 63e70fbc3837e36fbcc3e5b3d12eed74919e3beb
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Fri May 20 07:50:27 2011 -0700
> >
> >    ioc3-eth/meth/sgiseeq: Move the SGI drivers
> >
> >    Move the SGI drivers into drivers/net/ethernet/sgi/ and make the
> >    necessary Kconfig and Makefile changes.
> >
> >    CC: Ralf Baechle <ralf@linux-mips.org>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  MAINTAINERS                               |    2 +-
> >  drivers/net/Kconfig                       |   21 ----------------
> >  drivers/net/Makefile                      |    3 --
> >  drivers/net/ethernet/Kconfig              |    1 +
> >  drivers/net/ethernet/Makefile             |    1 +
> >  drivers/net/ethernet/sgi/Kconfig          |   37
> +++++++++++++++++++++++++++++
> >  drivers/net/ethernet/sgi/Makefile         |    7 +++++
> >  drivers/net/{ =3D> ethernet/sgi}/ioc3-eth.c |    0
> >  drivers/net/{ =3D> ethernet/sgi}/meth.c     |    0
> >  drivers/net/{ =3D> ethernet/sgi}/meth.h     |    0
> >  drivers/net/{ =3D> ethernet/sgi}/sgiseeq.c  |    0
> >  drivers/net/{ =3D> ethernet/sgi}/sgiseeq.h  |    0
> >  12 files changed, 47 insertions(+), 25 deletions(-)
> >
> > commit 33bb1962fa6983fb17a7c95a5b44be697878783b
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Fri May 20 07:15:19 2011 -0700
> >
> >    tulip: Move the tulip drivers
> >
> >    Move the tulip driver into drivers/net/ethernet/tulip/ and make
> >    the necessary Kconfig and Makefile changes.
> >
> >    CC: Tobias Ringstrom <tori@unhappy.mine.nu>
> >    CC: Grant Grundler <grundler@parisc-linux.org>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  MAINTAINERS                                    |    4 ++--
> >  drivers/net/Kconfig                            |    2 --
> >  drivers/net/Makefile                           |    1 -
> >  drivers/net/ethernet/Kconfig                   |    2 ++
> >  drivers/net/ethernet/Makefile                  |    1 +
> >  drivers/net/{ =3D> ethernet}/tulip/21142.c       |    0
> >  drivers/net/{ =3D> ethernet}/tulip/Kconfig       |    0
> >  drivers/net/{ =3D> ethernet}/tulip/Makefile      |    0
> >  drivers/net/{ =3D> ethernet}/tulip/de2104x.c     |    0
> >  drivers/net/{ =3D> ethernet}/tulip/de4x5.c       |    0
> >  drivers/net/{ =3D> ethernet}/tulip/de4x5.h       |    0
> >  drivers/net/{ =3D> ethernet}/tulip/dmfe.c        |    0
> >  drivers/net/{ =3D> ethernet}/tulip/eeprom.c      |    0
> >  drivers/net/{ =3D> ethernet}/tulip/interrupt.c   |    0
> >  drivers/net/{ =3D> ethernet}/tulip/media.c       |    0
> >  drivers/net/{ =3D> ethernet}/tulip/pnic.c        |    0
> >  drivers/net/{ =3D> ethernet}/tulip/pnic2.c       |    0
> >  drivers/net/{ =3D> ethernet}/tulip/timer.c       |    0
> >  drivers/net/{ =3D> ethernet}/tulip/tulip.h       |    0
> >  drivers/net/{ =3D> ethernet}/tulip/tulip_core.c  |    0
> >  drivers/net/{ =3D> ethernet}/tulip/uli526x.c     |    0
> >  drivers/net/{ =3D> ethernet}/tulip/winbond-840.c |    0
> >  drivers/net/{ =3D> ethernet}/tulip/xircom_cb.c   |    0
> >  23 files changed, 5 insertions(+), 5 deletions(-)
> >
> > commit 9091cea3242dcc16138cef784c4880a819b28c1e
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Fri May 20 06:55:16 2011 -0700
> >
> >    atl*: Move the Atheros drivers
> >
> >    Move the Atheros drivers into drivers/net/ethernet/atheros/ and
> >    make the necessary Kconfig and Makefile changes.
> >
> >    CC: Jay Cliburn <jcliburn@gmail.com>
> >    CC: Chris Snook <chris.snook@gmail.com>
> >    CC: Jie Yang <jie.yang@atheros.com>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  MAINTAINERS                                        |    2 +-
> >  drivers/net/Kconfig                                |   45
> --------------
> >  drivers/net/Makefile                               |    4 -
> >  drivers/net/ethernet/Kconfig                       |    1 +
> >  drivers/net/ethernet/Makefile                      |    1 +
> >  drivers/net/ethernet/atheros/Kconfig               |   61
> ++++++++++++++++++++
> >  drivers/net/ethernet/atheros/Makefile              |    8 +++
> >  drivers/net/{ =3D> ethernet/atheros}/atl1c/Makefile  |    0
> >  drivers/net/{ =3D> ethernet/atheros}/atl1c/atl1c.h   |    0
> >  .../{ =3D> ethernet/atheros}/atl1c/atl1c_ethtool.c   |    0
> >  .../net/{ =3D> ethernet/atheros}/atl1c/atl1c_hw.c    |    0
> >  .../net/{ =3D> ethernet/atheros}/atl1c/atl1c_hw.h    |    0
> >  .../net/{ =3D> ethernet/atheros}/atl1c/atl1c_main.c  |    0
> >  drivers/net/{ =3D> ethernet/atheros}/atl1e/Makefile  |    0
> >  drivers/net/{ =3D> ethernet/atheros}/atl1e/atl1e.h   |    0
> >  .../{ =3D> ethernet/atheros}/atl1e/atl1e_ethtool.c   |    0
> >  .../net/{ =3D> ethernet/atheros}/atl1e/atl1e_hw.c    |    0
> >  .../net/{ =3D> ethernet/atheros}/atl1e/atl1e_hw.h    |    0
> >  .../net/{ =3D> ethernet/atheros}/atl1e/atl1e_main.c  |    0
> >  .../net/{ =3D> ethernet/atheros}/atl1e/atl1e_param.c |    0
> >  drivers/net/{ =3D> ethernet/atheros}/atlx/Makefile   |    0
> >  drivers/net/{ =3D> ethernet/atheros}/atlx/atl1.c     |    0
> >  drivers/net/{ =3D> ethernet/atheros}/atlx/atl1.h     |    0
> >  drivers/net/{ =3D> ethernet/atheros}/atlx/atl2.c     |    0
> >  drivers/net/{ =3D> ethernet/atheros}/atlx/atl2.h     |    0
> >  drivers/net/{ =3D> ethernet/atheros}/atlx/atlx.c     |    0
> >  drivers/net/{ =3D> ethernet/atheros}/atlx/atlx.h     |    0
> >  27 files changed, 72 insertions(+), 50 deletions(-)
> >
> > commit c97cb6d3434e3a3fa4d415f436e04475df39e443
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Fri May 20 00:04:35 2011 -0700
> >
> >    de6*/dl2k: Move the D-Link drivers
> >
> >    Move the D-Link drivers into drivers/net/ethernet/dlink/ and
> >    make the necessary Kconfig and Makefile changes.
> >
> >    CC: Bjorn Ekwall <bj0rn@blox.se>
> >    CC: Donald Becker <becker@scyld.com>
> >    CC: Edward Peng <edward_peng@dlink.com.tw>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  drivers/net/Kconfig                      |   44
> ----------------------
> >  drivers/net/Makefile                     |    3 -
> >  drivers/net/ethernet/Kconfig             |    1 +
> >  drivers/net/ethernet/Makefile            |    1 +
> >  drivers/net/ethernet/dlink/Kconfig       |   60
> ++++++++++++++++++++++++++++++
> >  drivers/net/ethernet/dlink/Makefile      |    7 +++
> >  drivers/net/{ =3D> ethernet/dlink}/de600.c |    0
> >  drivers/net/{ =3D> ethernet/dlink}/de600.h |    0
> >  drivers/net/{ =3D> ethernet/dlink}/de620.c |    0
> >  drivers/net/{ =3D> ethernet/dlink}/de620.h |    0
> >  drivers/net/{ =3D> ethernet/dlink}/dl2k.c  |    0
> >  drivers/net/{ =3D> ethernet/dlink}/dl2k.h  |    0
> >  12 files changed, 69 insertions(+), 47 deletions(-)
> >
> > commit 268a0fa7d7159b37d1123d68343c555f44221510
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Thu May 19 23:27:55 2011 -0700
> >
> >    8139*/atp/r8169: Move the Realtek drivers
> >
> >    Move the Realtek drivers into drivers/net/ethernet/realtek/ and
> make
> >    the necessary Kconfig and Makefile changes.
> >
> >    CC: Realtek linux nic maintainers <nic_swsd@realtek.com>
> >    CC: Francois Romieu <romieu@fr.zoreil.com>
> >    CC: Jeff Garzik <jgarzik@pobox.com>
> >    CC: Donald Becker <becker@scyld.com>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  MAINTAINERS                                  |    2 +-
> >  drivers/net/Kconfig                          |   94
> ----------------------
> >  drivers/net/Makefile                         |    4 -
> >  drivers/net/ethernet/Kconfig                 |    1 +
> >  drivers/net/ethernet/Makefile                |    1 +
> >  drivers/net/{ =3D> ethernet/realtek}/8139cp.c  |    0
> >  drivers/net/{ =3D> ethernet/realtek}/8139too.c |    0
> >  drivers/net/ethernet/realtek/Kconfig         |  110
> ++++++++++++++++++++++++++
> >  drivers/net/ethernet/realtek/Makefile        |    8 ++
> >  drivers/net/{ =3D> ethernet/realtek}/atp.c     |    0
> >  drivers/net/{ =3D> ethernet/realtek}/atp.h     |    0
> >  drivers/net/{ =3D> ethernet/realtek}/r8169.c   |    0
> >  12 files changed, 121 insertions(+), 99 deletions(-)
> >
> > commit 5fe875b9e93af6b5a099b37471bebb541f1ba0c6
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Thu May 19 22:06:03 2011 -0700
> >
> >    arm: Move the ARM/ACORN drivers
> >
> >    Move the ARM/ACORN drivers into drivers/net/ethernet/arm/ and
> make the
> >    necessary Kconfig and Makefile changes.
> >    There were 4 drivers (TI Davinci & ftmac100) not in the
> >    drivers/net/arm/ which should have been since they are only
> supported
> >    under ARM, so they were added to the new directory structure.
> >
> >    NOTE: There are no "maintainers" for the TI Davinci drivers, so I
> am
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
> >  drivers/net/ethernet/arm/Kconfig               |  138
> ++++++++++++++++++++++++
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
> > commit 17c347d9648541503aef09b95b207737b151ddea
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Thu May 19 20:18:50 2011 -0700
> >
> >    smsc*/smc911x: Move the SMSC drivers
> >
> >    Move the SMSC drivers into drivers/net/ethernet/smsc/ and make
> the
> >    necessary Kconfig and Makefile changes.
> >
> >    CC: Dustin McIntire <dustin@sensoria.com>
> >    CC: Steve Glendinning <steve.glendinning@smsc.com>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  MAINTAINERS                                |    4 +-
> >  drivers/net/Kconfig                        |   54
> ---------------------
> >  drivers/net/Makefile                       |    3 -
> >  drivers/net/ethernet/Kconfig               |    1 +
> >  drivers/net/ethernet/Makefile              |    1 +
> >  drivers/net/ethernet/smsc/Kconfig          |   71
> ++++++++++++++++++++++++++++
> >  drivers/net/ethernet/smsc/Makefile         |    7 +++
> >  drivers/net/{ =3D> ethernet/smsc}/smc911x.c  |    0
> >  drivers/net/{ =3D> ethernet/smsc}/smc911x.h  |    0
> >  drivers/net/{ =3D> ethernet/smsc}/smsc911x.c |    0
> >  drivers/net/{ =3D> ethernet/smsc}/smsc911x.h |    0
> >  drivers/net/{ =3D> ethernet/smsc}/smsc9420.c |    0
> >  drivers/net/{ =3D> ethernet/smsc}/smsc9420.h |    0
> >  13 files changed, 82 insertions(+), 59 deletions(-)
> >
> > commit f93707a2948f67da9fbe12ff93f6c5a95d6fb23d
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Wed May 18 05:14:22 2011 -0700
> >
> >    *sonic/natsemi/ns83829: Move the National Semi-conductor drivers
> >
> >    Move the National Semi-conductor drivers into
> drivers/net/ethernet/natsemi/
> >    and make the necessary Kconfig and Makefile changes.  Also moved
> the 8390
> >    (National Semi-conductor) devices as a sub-menu of National
> Semi-conductor
> >    devices.
> >
> >    CC: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
> >    CC: Harald Welte <laforge@gnumonks.org>
> >    CC: Tim Hockin <thockin@hockin.org>
> >    CC: <linux-ns83820@kvack.org>
> >    CC: Kevin Chea <kchea@yahoo.com>
> >    CC: Marc Gauthier <marc@linux-xtensa.org>
> >    CC: Chris Zankel <chris@zankel.net>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  MAINTAINERS                                    |    4 +-
> >  drivers/net/Kconfig                            |   47
> ------------------
> >  drivers/net/Makefile                           |    6 --
> >  drivers/net/ethernet/8390/Kconfig              |    6 +-
> >  drivers/net/ethernet/Kconfig                   |    3 +-
> >  drivers/net/ethernet/Makefile                  |    1 +
> >  drivers/net/ethernet/natsemi/Kconfig           |   63
> ++++++++++++++++++++++++
> >  drivers/net/ethernet/natsemi/Makefile          |    9 +++
> >  drivers/net/{ =3D> ethernet/natsemi}/jazzsonic.c |    0
> >  drivers/net/{ =3D> ethernet/natsemi}/macsonic.c  |    0
> >  drivers/net/{ =3D> ethernet/natsemi}/natsemi.c   |    0
> >  drivers/net/{ =3D> ethernet/natsemi}/ns83820.c   |    0
> >  drivers/net/{ =3D> ethernet/natsemi}/sonic.c     |    0
> >  drivers/net/{ =3D> ethernet/natsemi}/sonic.h     |    0
> >  drivers/net/{ =3D> ethernet/natsemi}/xtsonic.c   |    0
> >  15 files changed, 80 insertions(+), 59 deletions(-)
> >
> > commit 8a352394d237f49f4d142874057d4179a1169607
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Mon May 16 01:39:01 2011 -0700
> >
> >    bmac/mace/macmace/mac89x0/cs89x0: Move the Macintosh (Apple)
> drivers
> >
> >    Move the Apple drivers into driver/net/ethernet/apple/ and make
> the
> >    necessary Kconfig and Makefile changes.
> >
> >    CC: Paul Mackerras <paulus@samba.org>
> >    CC: Paul Mackerras <paulus@au.ibm.com>
> >    CC: Russell Nelson <nelson@crynwr.com>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  drivers/net/Kconfig                        |   75
> ----------------------
> >  drivers/net/Makefile                       |    6 --
> >  drivers/net/ethernet/Kconfig               |    1 +
> >  drivers/net/ethernet/Makefile              |    1 +
> >  drivers/net/ethernet/apple/Kconfig         |   92
> ++++++++++++++++++++++++++++
> >  drivers/net/ethernet/apple/Makefile        |    9 +++
> >  drivers/net/{ =3D> ethernet/apple}/bmac.c    |    0
> >  drivers/net/{ =3D> ethernet/apple}/bmac.h    |    0
> >  drivers/net/{ =3D> ethernet/apple}/cs89x0.c  |    0
> >  drivers/net/{ =3D> ethernet/apple}/cs89x0.h  |    0
> >  drivers/net/{ =3D> ethernet/apple}/mac89x0.c |    0
> >  drivers/net/{ =3D> ethernet/apple}/mace.c    |    0
> >  drivers/net/{ =3D> ethernet/apple}/mace.h    |    0
> >  drivers/net/{ =3D> ethernet/apple}/macmace.c |    0
> >  14 files changed, 103 insertions(+), 81 deletions(-)
> >
> > commit 0222c318a10195f618d82f9f7c4e0d61564bcc5d
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Mon May 16 00:05:19 2011 -0700
> >
> >    stmmac: Move the STMicroelectronics driver
> >
> >    Move the STMicroelectronics driver into
> driver/net/ethernet/stmmac/ and
> >    make the necessary Kconfig and Makefile changes.
> >
> >    CC: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  MAINTAINERS                                        |    2 +-
> >  drivers/net/Kconfig                                |    2 --
> >  drivers/net/Makefile                               |    1 -
> >  drivers/net/ethernet/Kconfig                       |    1 +
> >  drivers/net/ethernet/Makefile                      |    1 +
> >  drivers/net/{ =3D> ethernet}/stmmac/Kconfig          |    0
> >  drivers/net/{ =3D> ethernet}/stmmac/Makefile         |    0
> >  drivers/net/{ =3D> ethernet}/stmmac/common.h         |    0
> >  drivers/net/{ =3D> ethernet}/stmmac/descs.h          |    0
> >  drivers/net/{ =3D> ethernet}/stmmac/dwmac100.h       |    0
> >  drivers/net/{ =3D> ethernet}/stmmac/dwmac1000.h      |    0
> >  drivers/net/{ =3D> ethernet}/stmmac/dwmac1000_core.c |    0
> >  drivers/net/{ =3D> ethernet}/stmmac/dwmac1000_dma.c  |    0
> >  drivers/net/{ =3D> ethernet}/stmmac/dwmac100_core.c  |    0
> >  drivers/net/{ =3D> ethernet}/stmmac/dwmac100_dma.c   |    0
> >  drivers/net/{ =3D> ethernet}/stmmac/dwmac_dma.h      |    0
> >  drivers/net/{ =3D> ethernet}/stmmac/dwmac_lib.c      |    0
> >  drivers/net/{ =3D> ethernet}/stmmac/enh_desc.c       |    0
> >  drivers/net/{ =3D> ethernet}/stmmac/norm_desc.c      |    0
> >  drivers/net/{ =3D> ethernet}/stmmac/stmmac.h         |    0
> >  drivers/net/{ =3D> ethernet}/stmmac/stmmac_ethtool.c |    0
> >  drivers/net/{ =3D> ethernet}/stmmac/stmmac_main.c    |    0
> >  drivers/net/{ =3D> ethernet}/stmmac/stmmac_mdio.c    |    0
> >  drivers/net/{ =3D> ethernet}/stmmac/stmmac_timer.c   |    0
> >  drivers/net/{ =3D> ethernet}/stmmac/stmmac_timer.h   |    0
> >  25 files changed, 3 insertions(+), 4 deletions(-)
> >
> > commit c9979075eda1f39b3cf73b51b4da05e2bc1a7a3f
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Sun May 15 21:46:41 2011 -0700
> >
> >    tehuti: Move the Tehuti driver
> >
> >    Move the Tehuti driver into drivers/net/ethernet/ and make the
> >    necessary Kconfig and Makefile changes.
> >
> >    CC: Alexander Indenbaum <baum@tehutinetworks.net>
> >    CC: Andy Gospodarek <andy@greyhouse.net>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  MAINTAINERS                         |    2 +-
> >  drivers/net/Kconfig                 |    6 ------
> >  drivers/net/Makefile                |    1 -
> >  drivers/net/ethernet/Kconfig        |    6 ++++++
> >  drivers/net/ethernet/Makefile       |    1 +
> >  drivers/net/{ =3D> ethernet}/tehuti.c |    0
> >  drivers/net/{ =3D> ethernet}/tehuti.h |    0
> >  7 files changed, 8 insertions(+), 8 deletions(-)
> >
> > commit 9b8448aa63ea26e8cbe23df6064146b2bcf1429c
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Sun May 15 20:56:37 2011 -0700
> >
> >    pasemic_mac*: Move the PA Semi driver
> >
> >    Move the PA Semi driver into drivers/net/ethernet/ and make the
> >    necessary Kconfig and Makefile changes.
> >
> >    CC: Olof Johansson <olof@lixom.net>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  MAINTAINERS                                     |    2 +-
> >  drivers/net/Kconfig                             |    9 ---------
> >  drivers/net/Makefile                            |    2 --
> >  drivers/net/ethernet/Kconfig                    |   10 ++++++++++
> >  drivers/net/ethernet/Makefile                   |    1 +
> >  drivers/net/{ =3D> ethernet}/pasemi_mac.c         |    0
> >  drivers/net/{ =3D> ethernet}/pasemi_mac.h         |    0
> >  drivers/net/{ =3D> ethernet}/pasemi_mac_ethtool.c |    0
> >  8 files changed, 12 insertions(+), 12 deletions(-)
> >
> > commit 8f45b84e5a50e13e530ccd7277e87e21bf9d3824
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Fri May 13 22:20:35 2011 -0700
> >
> >    enic: Move the Cisco driver
> >
> >    Move the Cisco driver into drivers/net/ethernet/enic/ and make
> the
> >    necessary Kconfig and Makefile changes.
> >
> >    CC: Scott Feldman <scofeldm@cisco.com>
> >    CC: Christian Benvenuti <benve@cisco.com>
> >    CC: Vasanthy Kolluri <vkolluri@cisco.com>
> >    CC: Roopa Prabhu <roprabhu@cisco.com>
> >    CC: David Wang <dwang2@cisco.com>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  MAINTAINERS                                     |    2 +-
> >  drivers/net/Kconfig                             |    6 ------
> >  drivers/net/Makefile                            |    1 -
> >  drivers/net/ethernet/Kconfig                    |    1 +
> >  drivers/net/ethernet/Makefile                   |    1 +
> >  drivers/net/ethernet/enic/Kconfig               |    9 +++++++++
> >  drivers/net/{ =3D> ethernet}/enic/Makefile        |    0
> >  drivers/net/{ =3D> ethernet}/enic/cq_desc.h       |    0
> >  drivers/net/{ =3D> ethernet}/enic/cq_enet_desc.h  |    0
> >  drivers/net/{ =3D> ethernet}/enic/enic.h          |    0
> >  drivers/net/{ =3D> ethernet}/enic/enic_dev.c      |    0
> >  drivers/net/{ =3D> ethernet}/enic/enic_dev.h      |    0
> >  drivers/net/{ =3D> ethernet}/enic/enic_main.c     |    0
> >  drivers/net/{ =3D> ethernet}/enic/enic_pp.c       |    0
> >  drivers/net/{ =3D> ethernet}/enic/enic_pp.h       |    0
> >  drivers/net/{ =3D> ethernet}/enic/enic_res.c      |    0
> >  drivers/net/{ =3D> ethernet}/enic/enic_res.h      |    0
> >  drivers/net/{ =3D> ethernet}/enic/rq_enet_desc.h  |    0
> >  drivers/net/{ =3D> ethernet}/enic/vnic_cq.c       |    0
> >  drivers/net/{ =3D> ethernet}/enic/vnic_cq.h       |    0
> >  drivers/net/{ =3D> ethernet}/enic/vnic_dev.c      |    0
> >  drivers/net/{ =3D> ethernet}/enic/vnic_dev.h      |    0
> >  drivers/net/{ =3D> ethernet}/enic/vnic_devcmd.h   |    0
> >  drivers/net/{ =3D> ethernet}/enic/vnic_enet.h     |    0
> >  drivers/net/{ =3D> ethernet}/enic/vnic_intr.c     |    0
> >  drivers/net/{ =3D> ethernet}/enic/vnic_intr.h     |    0
> >  drivers/net/{ =3D> ethernet}/enic/vnic_nic.h      |    0
> >  drivers/net/{ =3D> ethernet}/enic/vnic_resource.h |    0
> >  drivers/net/{ =3D> ethernet}/enic/vnic_rq.c       |    0
> >  drivers/net/{ =3D> ethernet}/enic/vnic_rq.h       |    0
> >  drivers/net/{ =3D> ethernet}/enic/vnic_rss.h      |    0
> >  drivers/net/{ =3D> ethernet}/enic/vnic_stats.h    |    0
> >  drivers/net/{ =3D> ethernet}/enic/vnic_vic.c      |    0
> >  drivers/net/{ =3D> ethernet}/enic/vnic_vic.h      |    0
> >  drivers/net/{ =3D> ethernet}/enic/vnic_wq.c       |    0
> >  drivers/net/{ =3D> ethernet}/enic/vnic_wq.h       |    0
> >  drivers/net/{ =3D> ethernet}/enic/wq_enet_desc.h  |    0
> >  37 files changed, 12 insertions(+), 8 deletions(-)
> >
> > commit 21b49617eef3976ebbd73cb4bf1a1f2f6902dbbf
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Fri May 13 14:29:12 2011 -0700
> >
> >    ehea/ibm*: Move the IBM drivers
> >
> >    Move the IBM drivers into drivers/net/ethernet/ibm/ and make the
> >    necessary Kconfig and Makefile changes.
> >
> >    CC: Christoph Raisch <raisch@de.ibm.com>
> >    CC: Alfred Arnold <alfred.arnold@lancom.de>
> >    CC: Santiago Leon <santil@linux.vnet.ibm.com>
> >    CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  MAINTAINERS                                        |    4 +-
> >  drivers/net/Kconfig                                |   37
> --------------
> >  drivers/net/Makefile                               |    4 --
> >  drivers/net/ethernet/Kconfig                       |    1 +
> >  drivers/net/ethernet/Makefile                      |    1 +
> >  drivers/net/ethernet/ibm/Kconfig                   |   53
> ++++++++++++++++++++
> >  drivers/net/ethernet/ibm/Makefile                  |    8 +++
> >  drivers/net/{ =3D> ethernet/ibm}/ehea/Makefile       |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ehea/ehea.h         |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ehea/ehea_ethtool.c |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ehea/ehea_hw.h      |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ehea/ehea_main.c    |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ehea/ehea_phyp.c    |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ehea/ehea_phyp.h    |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ehea/ehea_qmr.c     |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ehea/ehea_qmr.h     |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/Kconfig |    2 +-
> >  .../net/{ =3D> ethernet/ibm}/ibm_newemac/Makefile    |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/core.c  |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/core.h  |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/debug.c |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/debug.h |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/emac.h  |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/mal.c   |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/mal.h   |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/phy.c   |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/phy.h   |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/rgmii.c |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/rgmii.h |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/tah.c   |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/tah.h   |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/zmii.c  |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/zmii.h  |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ibmlana.c           |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ibmlana.h           |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ibmveth.c           |    0
> >  drivers/net/{ =3D> ethernet/ibm}/ibmveth.h           |    0
> >  37 files changed, 66 insertions(+), 44 deletions(-)
> >
> > commit a5c1daab860bc137dafadc061e48f4153ce89a31
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Fri May 13 02:51:01 2011 -0700
> >
> >    s2io/vxge: Move the Exar drivers
> >
> >    Move the Exar drivers into drivers/net/ethernet/exar/ and make
> the
> >    necessary Kconfig and Makefile changes.
> >
> >    CC: Jon Mason <jdmason@kudzu.us>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  MAINTAINERS                                        |    3 +-
> >  drivers/net/Kconfig                                |   34
> -------------
> >  drivers/net/Makefile                               |    2 -
> >  drivers/net/ethernet/Kconfig                       |    1 +
> >  drivers/net/ethernet/Makefile                      |    1 +
> >  drivers/net/ethernet/exar/Kconfig                  |   50
> ++++++++++++++++++++
> >  drivers/net/ethernet/exar/Makefile                 |    6 ++
> >  drivers/net/{ =3D> ethernet/exar}/s2io-regs.h        |    0
> >  drivers/net/{ =3D> ethernet/exar}/s2io.c             |    0
> >  drivers/net/{ =3D> ethernet/exar}/s2io.h             |    0
> >  drivers/net/{ =3D> ethernet/exar}/vxge/Makefile      |    0
> >  drivers/net/{ =3D> ethernet/exar}/vxge/vxge-config.c |    0
> >  drivers/net/{ =3D> ethernet/exar}/vxge/vxge-config.h |    0
> >  .../net/{ =3D> ethernet/exar}/vxge/vxge-ethtool.c    |    0
> >  .../net/{ =3D> ethernet/exar}/vxge/vxge-ethtool.h    |    0
> >  drivers/net/{ =3D> ethernet/exar}/vxge/vxge-main.c   |    0
> >  drivers/net/{ =3D> ethernet/exar}/vxge/vxge-main.h   |    0
> >  drivers/net/{ =3D> ethernet/exar}/vxge/vxge-reg.h    |    0
> >  .../net/{ =3D> ethernet/exar}/vxge/vxge-traffic.c    |    0
> >  .../net/{ =3D> ethernet/exar}/vxge/vxge-traffic.h    |    0
> >  .../net/{ =3D> ethernet/exar}/vxge/vxge-version.h    |    0
> >  21 files changed, 59 insertions(+), 38 deletions(-)
> >
> > commit 83df87d655e25119eafaeb4225bc5eedaa82c6e0
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Fri May 13 02:24:46 2011 -0700
> >
> >    myri*: Move the Myricom drivers
> >
> >    Move the Myricom drivers into drivers/net/ethernet/myricom/ and
> make
> >    the necessary Kconfig and Makefile changes.
> >
> >    CC: Andrew Gallatin <gallatin@myri.com>
> >    CC: Brice Goglin <brice@myri.com>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> >  MAINTAINERS                                        |    2 +-
> >  drivers/net/Kconfig                                |   35
> -------------
> >  drivers/net/Makefile                               |    3 -
> >  drivers/net/ethernet/Kconfig                       |    1 +
> >  drivers/net/ethernet/Makefile                      |    1 +
> >  drivers/net/ethernet/myricom/Kconfig               |   51
> ++++++++++++++++++++
> >  drivers/net/ethernet/myricom/Makefile              |    6 ++
> >  .../net/{ =3D> ethernet/myricom}/myri10ge/Makefile   |    0
> >  .../net/{ =3D> ethernet/myricom}/myri10ge/myri10ge.c |    0
> >  .../{ =3D> ethernet/myricom}/myri10ge/myri10ge_mcp.h |    0
> >  .../myricom}/myri10ge/myri10ge_mcp_gen_header.h    |    0
> >  drivers/net/{ =3D> ethernet/myricom}/myri_sbus.c     |    0
> >  drivers/net/{ =3D> ethernet/myricom}/myri_sbus.h     |    0
>=20
> /me puts on Myricom hat
>=20
> I believe we want to put the driver above in the sbus/legacy
> directory.  Better yet, move this driver to /dev/null.  There is no
> possibility of ethernet mode on this adapter, so it's Myrinet only.
> It won't inter-op with modern versions of Myrinet, and thus can only
> work with legacy adapters.  There are no drivers for the PCI version
> of this adapter, so it only can work on ~15year old hardware.  It's
> long in the tooth, let's take it to the knackers.
>=20
> Thanks,
> Jon=20

That sounds good.  Since I am not the maintainer or author of the
driver, I think such a move should come from Myricom.  I can drop the
move of myri_sbus.[ch] from my patches to organize the driver/net/
directory.

--=-/kGUdYv4PxPCRwQJlT4n
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJN/qmFAAoJECTsCADr/EWUfWQH/3Uztd8ntN/NtSTW2D5NPRkB
NoxWNHMh3aWlr/LLjOSywiYj1SkY0lhNH8ZX6vuGs24keXt2ZHid0Wh2k7OVT4Vg
dr6ftyfAqEo7a6vL2WxVm97fIdxJftuDqYhOZpxHmKyLJF7Tmzx+1MoVaWI4BlQn
KTEcP6FCGJvMHsOshViEfxjK1utNGxwoT6ayqD4BQ9hg+8eP9vip15GUcCJ67Z73
90jnxsvXl5r8U7qL8rkoR+0LVVd4uEU/jxLyyPD7HCc7DRIdqi6B7e7k71XO8d28
KskDHYbREdgtRwiF2lcTQvVdNoi4x60Fepa2u6QIebAwVc7r0+WU0GeQeU1LXP0=
=C8ib
-----END PGP SIGNATURE-----

--=-/kGUdYv4PxPCRwQJlT4n--

