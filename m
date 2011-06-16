From: Jon Mason <jon.mason@myri.com>
Subject: Re: [RFC] Moving files around in drivers/net
Date: Thu, 16 Jun 2011 10:03:27 -0500
Message-ID: <BANLkTin0QzAscKcN0Yw6rc7fUh5d5q143w@mail.gmail.com>
References: <1306956602.32125.28.camel@Joe-Laptop>
	<1306957998.3076.18.camel@jtkirshe-MOBL1>
	<1306958478.32125.32.camel@Joe-Laptop>
	<BANLkTi=BAqKzZeLF2_uCYnr7PD3StGFgAg@mail.gmail.com>
	<1308186619.12377.23.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Andrew Gallatin <gallatin@myri.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:44439 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753086Ab1FPPD2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 11:03:28 -0400
Received: by iwn34 with SMTP id 34so1203232iwn.19
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2011 08:03:28 -0700 (PDT)
In-Reply-To: <1308186619.12377.23.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 15, 2011 at 8:10 PM, Joe Perches <joe@perches.com> wrote:
> On Wed, 2011-06-15 at 11:38 -0700, Jeff Kirsher wrote:
>> On Wed, Jun 1, 2011 at 13:01, Joe Perches <joe@perches.com> wrote:
>> > On Wed, 2011-06-01 at 12:53 -0700, Jeff Kirsher wrote:
>> >> On Wed, 2011-06-01 at 12:30 -0700, Joe Perches wrote:
>> >> > Does anyone still think moving files around in drivers/net
>> >> > would be sensible and a suitable candidate for inclusion
>> >> > in 3.1?
>> >> > Here's what Jeffrey proposed:
>> >> > http://vger.kernel.org/netconf2010_slides/netconf-jtk.pdf
>> >> > Here's what I proposed before that.
>> >> > http://www.spinics.net/lists/netdev/msg149717.html
>> >> I am over 90% done with the work and have been trying to finish u=
p the
>> >> patches so that I could get them out as an RFC here in the next w=
eek.
>> > Excellent, thanks.
>> I thought for sure I would have finished what I have left by last
>> weekend, but I keep getting interrupted. =A0(Blame it on the NHL sta=
nley
>> cup playoffs) :)
>> I have created a git tree on kernel.org with all the work that I hav=
e
>> completed so far (see below). =A0This first stage of the move is onl=
y
>> taking care of the drivers. =A0The next stage will move the networki=
ng
>> core drivers (bridging, bonding, vlan, etc.) into drivers/net/sw.
>> git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-organize
>> I will send out all the patches as an RFC by the end of the week (fo=
r sure)
>
> I've put the body of the git log below my comments
> to make it easier to discuss.
>
> Comments:
>
> pktgen in hamachi/yellowfin should be pkteng
>
> I think it might be better if:
>
> Things were more spelled out:
> =A0 =A0 =A0 =A0pkteng should be packetengines
> And things maybe not spelled out
> =A0 =A0 =A0 =A0ixp2000 might just be ixp (what not intel?:)
>
> And maybe drivers/net/ethernet/ should be as
> unpopulated as possible. =A0Maybe create a misc
> directory and throw old unclassifiable junk there.
>
> Lance should be its own directory like 8390.
> I think a2065 and ariadne are lance drivers.
>
> Some manufacturer directories are directly populated
> with multiple drivers, some have subdirectories.
> Should one style be consistently used?
>
> pch_gbe should probably be oki.
>
> Isn't syskonnect now marvell?
>
> stmmac may not be a good name. =A0Maybe stmicro.
>
> enic may not be a good name. =A0Maybe cisco.
>
> mlx4 may be mellanox
>
> sfc may be solarflare
>
> bna may be brocade
>
> cheers, Joe
>
> $ git log --stat -M b7c7deeb4c77538577f0b6a724f10ce8693eb648..
> commit 743b1f134daef72805cb10e74d82dcbb95cd2568
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Tue Jun 14 14:02:57 2011 -0700
>
> =A0 =A0hamachi/yellowfin: Move the packet engine drivers
>
> =A0 =A0Move the packet engine drivers to drivers/net/ethernet/pktgen/=
 and
> =A0 =A0the necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Donald Becker <becker@scyld.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 26 ---------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0| =A0 =A02 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =
=A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A01 +
> =A0drivers/net/ethernet/pkteng/Kconfig =A0 =A0 =A0 =A0 =A0 | =A0 42 +=
++++++++++++++++++++++++
> =A0drivers/net/ethernet/pkteng/Makefile =A0 =A0 =A0 =A0 =A0| =A0 =A06=
 +++
> =A0drivers/net/{ =3D> ethernet/pkteng}/hamachi.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/pkteng}/yellowfin.c | =A0 =A00
> =A08 files changed, 50 insertions(+), 28 deletions(-)
>
> commit a7ce0b86340574f90bd24c460c3495ae3e06f5fb
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Tue Jun 14 13:35:31 2011 -0700
>
> =A0 =A0ixp2000: Move the Radisys driver
>
> =A0 =A0Move the Radisys driver into drivers/net/ethernet/ixp2000/ and
> =A0 =A0make the necessary Kconfig and Makefile changes
>
> =A0 =A0CC: Lennert Buytenhek <kernel@wantstofly.org>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0| =A0 =A02 --
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 | =A0 =A01 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0| =A0 =A01 +
> =A0drivers/net/{ =3D> ethernet}/ixp2000/Kconfig =A0 =A0 =A0 =A0 | =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/ixp2000/Makefile =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/ixp2000/caleb.c =A0 =A0 =A0 =A0 | =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/ixp2000/caleb.h =A0 =A0 =A0 =A0 | =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/ixp2000/enp2611.c =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/ixp2000/ixp2400-msf.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/ixp2000/ixp2400-msf.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/ixp2000/ixp2400_rx.uc =A0 | =A0 =A00
> =A0.../net/{ =3D> ethernet}/ixp2000/ixp2400_rx.ucode =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/ixp2000/ixp2400_tx.uc =A0 | =A0 =A00
> =A0.../net/{ =3D> ethernet}/ixp2000/ixp2400_tx.ucode =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/ixp2000/ixpdev.c =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/ixp2000/ixpdev.h =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/ixp2000/ixpdev_priv.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/ixp2000/pm3386.c =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/ixp2000/pm3386.h =A0 =A0 =A0 =A0| =A0=
 =A00
> =A021 files changed, 3 insertions(+), 4 deletions(-)
>
> commit 73091715bc0690f82ef9489f3589ad9b2d747cc0
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Tue Jun 14 12:56:50 2011 -0700
>
> =A0 =A0tlan/cpmac: Move the TI drivers
>
> =A0 =A0Move the TI drivers to drivers/net/ethernet/ti/ and make the
> =A0 =A0necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Samuel Chessman <chessman@tux.org>
> =A0 =A0CC: <torben.mathiasen@compaq.com>
> =A0 =A0CC: Eugene Konev <ejka@imfi.kspu.ru>
> =A0 =A0CC: Florian Fainelli <florian@openwrt.org>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =
=A0 =A04 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 25 -=
-------------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02=
 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0drivers/net/ethernet/ti/Kconfig =A0 =A0 =A0 | =A0 41 +++++++++++++=
++++++++++++++++++++
> =A0drivers/net/ethernet/ti/Makefile =A0 =A0 =A0| =A0 =A06 +++++
> =A0drivers/net/{ =3D> ethernet/ti}/cpmac.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/ti}/tlan.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/ti}/tlan.h =A0| =A0 =A00
> =A010 files changed, 51 insertions(+), 29 deletions(-)
>
> commit 035a452c66dbc0aa7873a12cfe057c74eaf89111
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Mon Jun 13 10:51:34 2011 -0700
>
> =A0 =A0s6gmac/tsi108_eth: Move the s6gmac/tsi108_eth drivers
>
> =A0 =A0Move the s6gmac/tsi108_eth drivers to drivers/net/ethernet/ an=
d
> =A0 =A0make the necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Oskar Schirmer <os@emlix.com>
> =A0 =A0CC: Kong Lai <kong.lai@tundra.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =
19 -------------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =
=A02 --
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0| =A0 21 +++++=
++++++++++++++++
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 | =A0 =A02 ++
> =A0drivers/net/{ =3D> ethernet}/s6gmac.c =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/tsi108_eth.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/tsi108_eth.h | =A0 =A00
> =A07 files changed, 23 insertions(+), 21 deletions(-)
>
> commit 4f9d3b9af95ced49b9ad9d5fb222f5216bf0adbb
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Mon Jun 13 10:03:01 2011 -0700
>
> =A0 =A0a2065/ariadne: Move the a2065/ariadne drivers
>
> =A0 =A0Move the a2065/ariadne drivers to drivers/net/ethernet/ and ma=
ke
> =A0 =A0the necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Geert Uytterhoeven <geert@linux-m68k.org>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 21 --=
-------------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 --
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 | =A0 23 ++++++++++++=
+++++++++++
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0| =A0 =A02 ++
> =A0drivers/net/{ =3D> ethernet}/a2065.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/a2065.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/ariadne.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/ariadne.h | =A0 =A00
> =A08 files changed, 25 insertions(+), 23 deletions(-)
>
> commit aead66521a701f08e3ae91aec7c9c8863a07a511
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Mon Jun 13 09:43:17 2011 -0700
>
> =A0 =A082586.c/fec*: Move the Motorola drivers
>
> =A0 =A0Move the Motorola drivers into drivers/net/ethernet/motorola/ =
and
> =A0 =A0make the necessary Kconfig and Makefile changes
>
> =A0 =A0CC: Dan Malek <dmalek@jlc.net>
> =A0 =A0CC: Sylvain Munaut <tnt@246tNt.com>
> =A0 =A0CC: Richard Hirst <richard@sleepie.demon.co.uk>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0| =A0 49 --------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 | =A0 =A07 --
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0| =A0 =A01 +
> =A0drivers/net/{ =3D> ethernet/motorola}/82596.c =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/ethernet/motorola/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 68 ++++++++++++++++++++
> =A0drivers/net/ethernet/motorola/Makefile =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 11 +++
> =A0drivers/net/{ =3D> ethernet/motorola}/fec.c =A0 =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet/motorola}/fec.h =A0 =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet/motorola}/fec_mpc52xx.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/motorola}/fec_mpc52xx.h =A0| =A0 =A00
> =A0.../net/{ =3D> ethernet/motorola}/fec_mpc52xx_phy.c =A0| =A0 =A00
> =A012 files changed, 81 insertions(+), 56 deletions(-)
>
> commit aebcb70982c66b54605fbd242f6ac035b2e205b3
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Mon Jun 13 08:43:49 2011 -0700
>
> =A0 =A0sis*: Move the Silicon Integrated Systems (SiS) drivers
>
> =A0 =A0Move the SiS drivers into drivers/net/ethernet/sis/ and make t=
he
> =A0 =A0necessary Kconfig and Makefile changes
>
> =A0 =A0CC: Daniele Venzano <venza@brownhat.org>
> =A0 =A0CC: Francois Romieu <romieu@fr.zoreil.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 | =A0 =A04 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =
30 --------------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =
=A02 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0drivers/net/ethernet/sis/Kconfig =A0 =A0 =A0 =A0| =A0 46 +++++++++=
++++++++++++++++++++++
> =A0drivers/net/ethernet/sis/Makefile =A0 =A0 =A0 | =A0 =A06 ++++
> =A0drivers/net/{ =3D> ethernet/sis}/sis190.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/sis}/sis900.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/sis}/sis900.h | =A0 =A00
> =A010 files changed, 56 insertions(+), 34 deletions(-)
>
> commit 826bef22759e1f78b284c9dc53ea442d348dbc88
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Mon Jun 13 08:23:31 2011 -0700
>
> =A0 =A0spider_net: Move the spider_net (IBM) driver
>
> =A0 =A0Move the spider_net (IBM) driver into drivers/net/ethernet/ibm=
/ and
> =A0 =A0make the necessary Kconfig and Makefile changes
>
> =A0 =A0CC: Utz Bacher <utz.bacher@de.ibm.com>
> =A0 =A0CC: Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
> =A0 =A0CC: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0| =A0 =A08 --------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 | =A0 =A02 --
> =A0drivers/net/ethernet/ibm/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 | =A0 11 ++++++++++-
> =A0drivers/net/ethernet/ibm/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0| =A0 =A02 ++
> =A0drivers/net/{ =3D> ethernet/ibm}/spider_net.c =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet/ibm}/spider_net.h =A0 =A0 =A0 =A0| =A0=
 =A02 +-
> =A0.../net/{ =3D> ethernet/ibm}/spider_net_ethtool.c =A0 =A0| =A0 =A0=
0
> =A08 files changed, 14 insertions(+), 13 deletions(-)
>
> commit 776fae874e79c3bf3b6fd81eceb23993fef76c01
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Mon Jun 13 07:56:34 2011 -0700
>
> =A0 =A0mv643xx/pxa168: Move the Marvell drivers
>
> =A0 =A0Move the Marvell drivers into driver/net/ethernet/marvell and =
make
> =A0 =A0the necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Sachin Sanap <ssanap@marvell.com>
> =A0 =A0CC: Zhangfei Gao <zgao6@marvell.com>
> =A0 =A0CC: Philip Rakity <prakity@marvell.com>
> =A0 =A0CC: Mark Brown <markb@marvell.com>
> =A0 =A0CC: Lennert Buytenhek <buytenh@marvell.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0| =A0 23 ------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 | =A0 =A02 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 | =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0| =A0 =A01 +
> =A0drivers/net/ethernet/marvell/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 40 ++++++++++++++++++++++
> =A0drivers/net/ethernet/marvell/Makefile =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 =A06 +++
> =A0drivers/net/{ =3D> ethernet/marvell}/mv643xx_eth.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/marvell}/pxa168_eth.c =A0| =A0 =A00
> =A09 files changed, 49 insertions(+), 26 deletions(-)
>
> commit 4153aed9e3020693985219d471f8eb230a8eaefa
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Sat Jun 11 03:26:31 2011 -0700
>
> =A0 =A0ks8*/ksz8*: Move the Micrel drivers
>
> =A0 =A0Move the Micrel drivers into drivers/net/ethernet/micrel/ and
> =A0 =A0make the necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Ben Dooks <ben@simtec.co.uk>
> =A0 =A0CC: Tristram Ha <Tristram.Ha@micrel.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0| =A0 35 ----------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A04 --
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 |=
 =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 =A01 +
> =A0drivers/net/ethernet/micrel/Kconfig =A0 =A0 =A0 =A0 =A0 =A0| =A0 5=
1 ++++++++++++++++++++++++
> =A0drivers/net/ethernet/micrel/Makefile =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
8 ++++
> =A0drivers/net/{ =3D> ethernet/micrel}/ks8842.c =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/micrel}/ks8851.c =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/micrel}/ks8851.h =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/micrel}/ks8851_mll.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/micrel}/ksz884x.c =A0 =A0| =A0 =A00
> =A011 files changed, 61 insertions(+), 39 deletions(-)
>
> commit 518f5abc833cb0c30b79161c071b7c93ed458c6d
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Sat Jun 11 02:29:36 2011 -0700
>
> =A0 =A0fsl_*/gianfar*/ucc_*: Move the Freescale drivers
>
> =A0 =A0Move the Freescale driver into drivers/net/ethernet/freescale/=
 and
> =A0 =A0make the necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Sandeep Gopalpet <sandeep.kumar@freescale.com>
> =A0 =A0CC: Andy Fleming <afleming@freescale.com>
> =A0 =A0CC: Shlomi Gridish <gridish@freescale.com>
> =A0 =A0CC: Li Yang <leoli@freescale.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0| =A0 33 -------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 | =A0 14 ------
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0| =A0 =A01 +
> =A0drivers/net/ethernet/freescale/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 48 ++++++++++++++++++++
> =A0drivers/net/ethernet/freescale/Makefile =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 13 +++++
> =A0.../net/{ =3D> ethernet/freescale}/fs_enet/Kconfig =A0 | =A0 =A02 =
+-
> =A0.../net/{ =3D> ethernet/freescale}/fs_enet/Makefile =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/freescale}/fs_enet/fec.h | =A0 =A00
> =A0.../freescale}/fs_enet/fs_enet-main.c =A0 =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 =A00
> =A0.../net/{ =3D> ethernet/freescale}/fs_enet/fs_enet.h | =A0 =A00
> =A0.../net/{ =3D> ethernet/freescale}/fs_enet/mac-fcc.c | =A0 =A00
> =A0.../net/{ =3D> ethernet/freescale}/fs_enet/mac-fec.c | =A0 =A00
> =A0.../net/{ =3D> ethernet/freescale}/fs_enet/mac-scc.c | =A0 =A00
> =A0.../{ =3D> ethernet/freescale}/fs_enet/mii-bitbang.c | =A0 =A00
> =A0.../net/{ =3D> ethernet/freescale}/fs_enet/mii-fec.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/freescale}/fsl_pq_mdio.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/freescale}/fsl_pq_mdio.h | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/freescale}/gianfar.c =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/freescale}/gianfar.h =A0 =A0 | =A0 =A0=
0
> =A0.../net/{ =3D> ethernet/freescale}/gianfar_ethtool.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/freescale}/gianfar_ptp.c | =A0 =A00
> =A0.../net/{ =3D> ethernet/freescale}/gianfar_sysfs.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/freescale}/ucc_geth.c =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/freescale}/ucc_geth.h =A0 =A0| =A0 =A0=
0
> =A0.../{ =3D> ethernet/freescale}/ucc_geth_ethtool.c =A0 =A0| =A0 =A0=
0
> =A027 files changed, 65 insertions(+), 49 deletions(-)
>
> commit dbf507c912fcc804a20d86d2194fc4a4298f39df
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Sat Jun 11 01:13:22 2011 -0700
>
> =A0 =A0eepro/eexpress/eth16i/ewrk3/lp486e/seeq8005/znet: Move the ISA=
 drivers
>
> =A0 =A0Move the ISA drivers into drivers/net/ethernet/isa/ and make t=
he
> =A0 =A0necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Philip Blundell <philb@gnu.org>
> =A0 =A0CC: Mika Kuoppala <miku@iki.fi>
> =A0 =A0CC: <bao.ha@srs.gov>
> =A0 =A0CC: <aris@cathedrallabs.org>
> =A0 =A0CC: David Davies <davies@maniac.ultranet.com>
> =A0 =A0CC: <aeb@cwi.nl>
> =A0 =A0CC: Hamish Coleman <hamish@zot.apana.org.au>
> =A0 =A0CC: Donald Becker <becker@scyld.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A04 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =
=A0 98 ----------------------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =
=A0 10 ---
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01=
 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0drivers/net/ethernet/isa/Kconfig =A0 =A0 =A0 =A0 =A0| =A0101 +++++=
++++++++++++++++++++++++
> =A0drivers/net/ethernet/isa/Makefile =A0 =A0 =A0 =A0 | =A0 11 +++
> =A0drivers/net/{ =3D> ethernet/isa}/eepro.c =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/isa}/eexpress.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/isa}/eexpress.h | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/isa}/eth16i.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/isa}/ewrk3.c =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/isa}/ewrk3.h =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/isa}/lp486e.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/isa}/seeq8005.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/isa}/seeq8005.h | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/isa}/znet.c =A0 =A0 | =A0 =A00
> =A017 files changed, 116 insertions(+), 110 deletions(-)
>
> commit b8a6199b8d692ae17932b8c8cc709898255a51ad
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Fri May 20 20:43:09 2011 -0700
>
> =A0 =A0via-*: Move the VIA drivers
>
> =A0 =A0Move the VIA drivers into drivers/net/ethernet/via/ and make t=
he
> =A0 =A0necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Roger Luethi <rl@hellgate.ch>
> =A0 =A0CC: Francois Romieu <romieu@fr.zoreil.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 | =A0 =A04 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 36 -----------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0| =A0 =A02 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =
=A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A01 +
> =A0drivers/net/ethernet/via/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =
52 +++++++++++++++++++++++++
> =A0drivers/net/ethernet/via/Makefile =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
6 +++
> =A0drivers/net/{ =3D> ethernet/via}/via-rhine.c =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/via}/via-velocity.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/via}/via-velocity.h | =A0 =A00
> =A010 files changed, 62 insertions(+), 40 deletions(-)
>
> commit 0cc82a49e423bc0b2ee19c49ad24376d1ffccdc5
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Fri May 20 20:18:55 2011 -0700
>
> =A0 =A0skge/sky2: Move the SysKonnect Ethernet drivers
>
> =A0 =A0Move the SysKonnect (Ethernet only) drivers into drivers/net/e=
thernet/syskonnect/
> =A0 =A0and make the necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Stephen Hemminger <shemminger@linux-foundation.org>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0| =A0 =A03 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0| =A0 58 --------------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 | =A0 =A02 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 =A01 +
> =A0drivers/net/ethernet/syskonnect/Kconfig =A0 =A0 =A0| =A0 74 ++++++=
++++++++++++++++++++
> =A0drivers/net/ethernet/syskonnect/Makefile =A0 =A0 | =A0 =A06 ++
> =A0drivers/net/{ =3D> ethernet/syskonnect}/skge.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/syskonnect}/skge.h | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/syskonnect}/sky2.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/syskonnect}/sky2.h | =A0 =A00
> =A011 files changed, 83 insertions(+), 62 deletions(-)
>
> commit c9e8faa7214a8911a22281e6e688e0cc69bb54b8
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Fri May 20 19:48:55 2011 -0700
>
> =A0 =A0pch_gbe: Move the OKI driver
>
> =A0 =A0Move the OKI driver into driver/net/ethernet/pch_gbe/ and make=
 the
> =A0 =A0necessary Kconfig and Makefile changes.
>
> =A0 =A0Note: there is no documented maintainer for this driver, so I =
CC'd
> =A0 =A0the last 2 major contributors.
>
> =A0 =A0CC: Tomoya <tomoya-linux@dsn.okisemi.com>
> =A0 =A0CC: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0| =A0 19 -------------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 | =A0 =A01 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0| =A0 =A01 +
> =A0drivers/net/ethernet/pch_gbe/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 |=
 =A0 20 ++++++++++++++++++++
> =A0drivers/net/{ =3D> ethernet}/pch_gbe/Makefile =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/pch_gbe/pch_gbe.h =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/pch_gbe/pch_gbe_api.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/pch_gbe/pch_gbe_api.h =A0 | =A0 =A00
> =A0.../net/{ =3D> ethernet}/pch_gbe/pch_gbe_ethtool.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/pch_gbe/pch_gbe_main.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/pch_gbe/pch_gbe_param.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/pch_gbe/pch_gbe_phy.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/pch_gbe/pch_gbe_phy.h =A0 | =A0 =A00
> =A014 files changed, 22 insertions(+), 20 deletions(-)
>
> commit 63e70fbc3837e36fbcc3e5b3d12eed74919e3beb
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Fri May 20 07:50:27 2011 -0700
>
> =A0 =A0ioc3-eth/meth/sgiseeq: Move the SGI drivers
>
> =A0 =A0Move the SGI drivers into drivers/net/ethernet/sgi/ and make t=
he
> =A0 =A0necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Ralf Baechle <ralf@linux-mips.org>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A02 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =
=A0 21 ----------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =
=A0 =A03 --
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01=
 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0drivers/net/ethernet/sgi/Kconfig =A0 =A0 =A0 =A0 =A0| =A0 37 +++++=
++++++++++++++++++++++++
> =A0drivers/net/ethernet/sgi/Makefile =A0 =A0 =A0 =A0 | =A0 =A07 +++++
> =A0drivers/net/{ =3D> ethernet/sgi}/ioc3-eth.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/sgi}/meth.c =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/sgi}/meth.h =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/sgi}/sgiseeq.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/sgi}/sgiseeq.h =A0| =A0 =A00
> =A012 files changed, 47 insertions(+), 25 deletions(-)
>
> commit 33bb1962fa6983fb17a7c95a5b44be697878783b
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Fri May 20 07:15:19 2011 -0700
>
> =A0 =A0tulip: Move the tulip drivers
>
> =A0 =A0Move the tulip driver into drivers/net/ethernet/tulip/ and mak=
e
> =A0 =A0the necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Tobias Ringstrom <tori@unhappy.mine.nu>
> =A0 =A0CC: Grant Grundler <grundler@parisc-linux.org>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0| =A0 =A04 ++--
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0| =A0 =A02 --
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A01 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 |=
 =A0 =A02 ++
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 =A01 +
> =A0drivers/net/{ =3D> ethernet}/tulip/21142.c =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/tulip/Kconfig =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/tulip/Makefile =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/tulip/de2104x.c =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/tulip/de4x5.c =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/tulip/de4x5.h =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/tulip/dmfe.c =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/tulip/eeprom.c =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/tulip/interrupt.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/tulip/media.c =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/tulip/pnic.c =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/tulip/pnic2.c =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/tulip/timer.c =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/tulip/tulip.h =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/tulip/tulip_core.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/tulip/uli526x.c =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/tulip/winbond-840.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/tulip/xircom_cb.c =A0 | =A0 =A00
> =A023 files changed, 5 insertions(+), 5 deletions(-)
>
> commit 9091cea3242dcc16138cef784c4880a819b28c1e
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Fri May 20 06:55:16 2011 -0700
>
> =A0 =A0atl*: Move the Atheros drivers
>
> =A0 =A0Move the Atheros drivers into drivers/net/ethernet/atheros/ an=
d
> =A0 =A0make the necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Jay Cliburn <jcliburn@gmail.com>
> =A0 =A0CC: Chris Snook <chris.snook@gmail.com>
> =A0 =A0CC: Jie Yang <jie.yang@atheros.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0| =A0 45 --------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 | =A0 =A04 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0| =A0 =A01 +
> =A0drivers/net/ethernet/atheros/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 |=
 =A0 61 ++++++++++++++++++++
> =A0drivers/net/ethernet/atheros/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 =A08 +++
> =A0drivers/net/{ =3D> ethernet/atheros}/atl1c/Makefile =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/atheros}/atl1c/atl1c.h =A0 | =A0 =A00
> =A0.../{ =3D> ethernet/atheros}/atl1c/atl1c_ethtool.c =A0 | =A0 =A00
> =A0.../net/{ =3D> ethernet/atheros}/atl1c/atl1c_hw.c =A0 =A0| =A0 =A0=
0
> =A0.../net/{ =3D> ethernet/atheros}/atl1c/atl1c_hw.h =A0 =A0| =A0 =A0=
0
> =A0.../net/{ =3D> ethernet/atheros}/atl1c/atl1c_main.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/atheros}/atl1e/Makefile =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/atheros}/atl1e/atl1e.h =A0 | =A0 =A00
> =A0.../{ =3D> ethernet/atheros}/atl1e/atl1e_ethtool.c =A0 | =A0 =A00
> =A0.../net/{ =3D> ethernet/atheros}/atl1e/atl1e_hw.c =A0 =A0| =A0 =A0=
0
> =A0.../net/{ =3D> ethernet/atheros}/atl1e/atl1e_hw.h =A0 =A0| =A0 =A0=
0
> =A0.../net/{ =3D> ethernet/atheros}/atl1e/atl1e_main.c =A0| =A0 =A00
> =A0.../net/{ =3D> ethernet/atheros}/atl1e/atl1e_param.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/atheros}/atlx/Makefile =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/atheros}/atlx/atl1.c =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/atheros}/atlx/atl1.h =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/atheros}/atlx/atl2.c =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/atheros}/atlx/atl2.h =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/atheros}/atlx/atlx.c =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/atheros}/atlx/atlx.h =A0 =A0 | =A0 =A0=
0
> =A027 files changed, 72 insertions(+), 50 deletions(-)
>
> commit c97cb6d3434e3a3fa4d415f436e04475df39e443
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Fri May 20 00:04:35 2011 -0700
>
> =A0 =A0de6*/dl2k: Move the D-Link drivers
>
> =A0 =A0Move the D-Link drivers into drivers/net/ethernet/dlink/ and
> =A0 =A0make the necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Bjorn Ekwall <bj0rn@blox.se>
> =A0 =A0CC: Donald Becker <becker@scyld.com>
> =A0 =A0CC: Edward Peng <edward_peng@dlink.com.tw>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 44 ----------------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A03 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
> =A0drivers/net/ethernet/dlink/Kconfig =A0 =A0 =A0 | =A0 60 ++++++++++=
++++++++++++++++++++
> =A0drivers/net/ethernet/dlink/Makefile =A0 =A0 =A0| =A0 =A07 +++
> =A0drivers/net/{ =3D> ethernet/dlink}/de600.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/dlink}/de600.h | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/dlink}/de620.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/dlink}/de620.h | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/dlink}/dl2k.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/dlink}/dl2k.h =A0| =A0 =A00
> =A012 files changed, 69 insertions(+), 47 deletions(-)
>
> commit 268a0fa7d7159b37d1123d68343c555f44221510
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Thu May 19 23:27:55 2011 -0700
>
> =A0 =A08139*/atp/r8169: Move the Realtek drivers
>
> =A0 =A0Move the Realtek drivers into drivers/net/ethernet/realtek/ an=
d make
> =A0 =A0the necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Realtek linux nic maintainers <nic_swsd@realtek.com>
> =A0 =A0CC: Francois Romieu <romieu@fr.zoreil.com>
> =A0 =A0CC: Jeff Garzik <jgarzik@pobox.com>
> =A0 =A0CC: Donald Becker <becker@scyld.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0| =A0 =A02 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0| =A0 94 ----------------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 | =A0 =A04 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 =A01 +
> =A0drivers/net/{ =3D> ethernet/realtek}/8139cp.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/realtek}/8139too.c | =A0 =A00
> =A0drivers/net/ethernet/realtek/Kconfig =A0 =A0 =A0 =A0 | =A0110 ++++=
++++++++++++++++++++++
> =A0drivers/net/ethernet/realtek/Makefile =A0 =A0 =A0 =A0| =A0 =A08 ++
> =A0drivers/net/{ =3D> ethernet/realtek}/atp.c =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/realtek}/atp.h =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/realtek}/r8169.c =A0 | =A0 =A00
> =A012 files changed, 121 insertions(+), 99 deletions(-)
>
> commit 5fe875b9e93af6b5a099b37471bebb541f1ba0c6
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Thu May 19 22:06:03 2011 -0700
>
> =A0 =A0arm: Move the ARM/ACORN drivers
>
> =A0 =A0Move the ARM/ACORN drivers into drivers/net/ethernet/arm/ and =
make the
> =A0 =A0necessary Kconfig and Makefile changes.
> =A0 =A0There were 4 drivers (TI Davinci & ftmac100) not in the
> =A0 =A0drivers/net/arm/ which should have been since they are only su=
pported
> =A0 =A0under ARM, so they were added to the new directory structure.
>
> =A0 =A0NOTE: There are no "maintainers" for the TI Davinci drivers, s=
o I am
> =A0 =A0CC'ing the last 3 major contributors from TI.
>
> =A0 =A0CC: Sriram <srk@ti.com>
> =A0 =A0CC: Vinay Hegde <vinay.hegde@ti.com>
> =A0 =A0CC: Cyril Chemparathy <cyril@ti.com>
> =A0 =A0CC: Russell King <linux@arm.linux.org.uk>
> =A0 =A0CC: Wan ZongShun <mcuos.com@gmail.com>
> =A0 =A0CC: Lennert Buytenhek <kernel@wantstofly.org>
> =A0 =A0CC: Krzysztof Halasa <khc@pm.waw.pl>
> =A0 =A0CC: Po-Yu Chuang <ratbert@faraday-tech.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0| =A0 10 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0| =A0 51 ---------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A07 --
> =A0drivers/net/arm/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0| =A0 74 -------------
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 |=
 =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 =A01 +
> =A0drivers/net/ethernet/arm/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
138 ++++++++++++++++++++++++
> =A0drivers/net/{ =3D> ethernet}/arm/Makefile =A0 =A0 =A0 =A0| =A0 =A0=
6 +-
> =A0drivers/net/{ =3D> ethernet}/arm/am79c961a.c =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/arm/am79c961a.h =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/arm/at91_ether.c =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/arm/at91_ether.h =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/arm}/davinci_cpdma.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/arm}/davinci_cpdma.h | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/arm}/davinci_emac.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/arm}/davinci_mdio.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/arm/ep93xx_eth.c =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/arm/ether1.c =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/arm/ether1.h =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/arm/ether3.c =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/arm/ether3.h =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/arm/etherh.c =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/arm}/ftgmac100.c =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/arm}/ftgmac100.h =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/arm}/ftmac100.c =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/arm}/ftmac100.h =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/arm/ixp4xx_eth.c =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/arm/ks8695net.c =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/arm/ks8695net.h =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/arm/w90p910_ether.c | =A0 =A00
> =A030 files changed, 150 insertions(+), 138 deletions(-)
>
> commit 17c347d9648541503aef09b95b207737b151ddea
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Thu May 19 20:18:50 2011 -0700
>
> =A0 =A0smsc*/smc911x: Move the SMSC drivers
>
> =A0 =A0Move the SMSC drivers into drivers/net/ethernet/smsc/ and make=
 the
> =A0 =A0necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Dustin McIntire <dustin@sensoria.com>
> =A0 =A0CC: Steve Glendinning <steve.glendinning@smsc.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0| =A0 =A04 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
| =A0 54 ---------------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 |=
 =A0 =A03 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
1 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0=
1 +
> =A0drivers/net/ethernet/smsc/Kconfig =A0 =A0 =A0 =A0 =A0| =A0 71 ++++=
++++++++++++++++++++++++
> =A0drivers/net/ethernet/smsc/Makefile =A0 =A0 =A0 =A0 | =A0 =A07 +++
> =A0drivers/net/{ =3D> ethernet/smsc}/smc911x.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/smsc}/smc911x.h =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/smsc}/smsc911x.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/smsc}/smsc911x.h | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/smsc}/smsc9420.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/smsc}/smsc9420.h | =A0 =A00
> =A013 files changed, 82 insertions(+), 59 deletions(-)
>
> commit f93707a2948f67da9fbe12ff93f6c5a95d6fb23d
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Wed May 18 05:14:22 2011 -0700
>
> =A0 =A0*sonic/natsemi/ns83829: Move the National Semi-conductor drive=
rs
>
> =A0 =A0Move the National Semi-conductor drivers into drivers/net/ethe=
rnet/natsemi/
> =A0 =A0and make the necessary Kconfig and Makefile changes. =A0Also m=
oved the 8390
> =A0 =A0(National Semi-conductor) devices as a sub-menu of National Se=
mi-conductor
> =A0 =A0devices.
>
> =A0 =A0CC: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
> =A0 =A0CC: Harald Welte <laforge@gnumonks.org>
> =A0 =A0CC: Tim Hockin <thockin@hockin.org>
> =A0 =A0CC: <linux-ns83820@kvack.org>
> =A0 =A0CC: Kevin Chea <kchea@yahoo.com>
> =A0 =A0CC: Marc Gauthier <marc@linux-xtensa.org>
> =A0 =A0CC: Chris Zankel <chris@zankel.net>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0| =A0 =A04 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0| =A0 47 ------------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A06 --
> =A0drivers/net/ethernet/8390/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 =A06 +-
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 |=
 =A0 =A03 +-
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 =A01 +
> =A0drivers/net/ethernet/natsemi/Kconfig =A0 =A0 =A0 =A0 =A0 | =A0 63 =
++++++++++++++++++++++++
> =A0drivers/net/ethernet/natsemi/Makefile =A0 =A0 =A0 =A0 =A0| =A0 =A0=
9 +++
> =A0drivers/net/{ =3D> ethernet/natsemi}/jazzsonic.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/natsemi}/macsonic.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/natsemi}/natsemi.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/natsemi}/ns83820.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/natsemi}/sonic.c =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/natsemi}/sonic.h =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/natsemi}/xtsonic.c =A0 | =A0 =A00
> =A015 files changed, 80 insertions(+), 59 deletions(-)
>
> commit 8a352394d237f49f4d142874057d4179a1169607
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Mon May 16 01:39:01 2011 -0700
>
> =A0 =A0bmac/mace/macmace/mac89x0/cs89x0: Move the Macintosh (Apple) d=
rivers
>
> =A0 =A0Move the Apple drivers into driver/net/ethernet/apple/ and mak=
e the
> =A0 =A0necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Paul Mackerras <paulus@samba.org>
> =A0 =A0CC: Paul Mackerras <paulus@au.ibm.com>
> =A0 =A0CC: Russell Nelson <nelson@crynwr.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
| =A0 75 ----------------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 |=
 =A0 =A06 --
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
1 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0=
1 +
> =A0drivers/net/ethernet/apple/Kconfig =A0 =A0 =A0 =A0 | =A0 92 ++++++=
++++++++++++++++++++++
> =A0drivers/net/ethernet/apple/Makefile =A0 =A0 =A0 =A0| =A0 =A09 +++
> =A0drivers/net/{ =3D> ethernet/apple}/bmac.c =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/apple}/bmac.h =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/apple}/cs89x0.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/apple}/cs89x0.h =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/apple}/mac89x0.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/apple}/mace.c =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/apple}/mace.h =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/apple}/macmace.c | =A0 =A00
> =A014 files changed, 103 insertions(+), 81 deletions(-)
>
> commit 0222c318a10195f618d82f9f7c4e0d61564bcc5d
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Mon May 16 00:05:19 2011 -0700
>
> =A0 =A0stmmac: Move the STMicroelectronics driver
>
> =A0 =A0Move the STMicroelectronics driver into driver/net/ethernet/st=
mmac/ and
> =A0 =A0make the necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0| =A0 =A02 --
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 | =A0 =A01 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0| =A0 =A01 +
> =A0drivers/net/{ =3D> ethernet}/stmmac/Kconfig =A0 =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/stmmac/Makefile =A0 =A0 =A0 =A0 | =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/stmmac/common.h =A0 =A0 =A0 =A0 | =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/stmmac/descs.h =A0 =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/stmmac/dwmac100.h =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/stmmac/dwmac1000.h =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/stmmac/dwmac1000_core.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/stmmac/dwmac1000_dma.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/stmmac/dwmac100_core.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/stmmac/dwmac100_dma.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/stmmac/dwmac_dma.h =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/stmmac/dwmac_lib.c =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/stmmac/enh_desc.c =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/stmmac/norm_desc.c =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/stmmac/stmmac.h =A0 =A0 =A0 =A0 | =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/stmmac/stmmac_ethtool.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/stmmac/stmmac_main.c =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/stmmac/stmmac_mdio.c =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/stmmac/stmmac_timer.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/stmmac/stmmac_timer.h =A0 | =A0 =A00
> =A025 files changed, 3 insertions(+), 4 deletions(-)
>
> commit c9979075eda1f39b3cf73b51b4da05e2bc1a7a3f
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Sun May 15 21:46:41 2011 -0700
>
> =A0 =A0tehuti: Move the Tehuti driver
>
> =A0 =A0Move the Tehuti driver into drivers/net/ethernet/ and make the
> =A0 =A0necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Alexander Indenbaum <baum@tehutinetworks.net>
> =A0 =A0CC: Andy Gospodarek <andy@greyhouse.net>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =
=A02 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A06 ---=
---
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0| =A0 =A06 ++++++
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 | =A0 =A01 +
> =A0drivers/net/{ =3D> ethernet}/tehuti.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/tehuti.h | =A0 =A00
> =A07 files changed, 8 insertions(+), 8 deletions(-)
>
> commit 9b8448aa63ea26e8cbe23df6064146b2bcf1429c
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Sun May 15 20:56:37 2011 -0700
>
> =A0 =A0pasemic_mac*: Move the PA Semi driver
>
> =A0 =A0Move the PA Semi driver into drivers/net/ethernet/ and make th=
e
> =A0 =A0necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Olof Johansson <olof@lixom.net>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 | =A0 =A09 ---------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0| =A0 =A02 --
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
| =A0 10 ++++++++++
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
| =A0 =A01 +
> =A0drivers/net/{ =3D> ethernet}/pasemi_mac.c =A0 =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/pasemi_mac.h =A0 =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/pasemi_mac_ethtool.c | =A0 =A00
> =A08 files changed, 12 insertions(+), 12 deletions(-)
>
> commit 8f45b84e5a50e13e530ccd7277e87e21bf9d3824
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Fri May 13 22:20:35 2011 -0700
>
> =A0 =A0enic: Move the Cisco driver
>
> =A0 =A0Move the Cisco driver into drivers/net/ethernet/enic/ and make=
 the
> =A0 =A0necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Scott Feldman <scofeldm@cisco.com>
> =A0 =A0CC: Christian Benvenuti <benve@cisco.com>
> =A0 =A0CC: Vasanthy Kolluri <vkolluri@cisco.com>
> =A0 =A0CC: Roopa Prabhu <roprabhu@cisco.com>
> =A0 =A0CC: David Wang <dwang2@cisco.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 | =A0 =A06 ------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0| =A0 =A01 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
| =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
| =A0 =A01 +
> =A0drivers/net/ethernet/enic/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A09 +++++++++
> =A0drivers/net/{ =3D> ethernet}/enic/Makefile =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/enic/cq_desc.h =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/cq_enet_desc.h =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/enic.h =A0 =A0 =A0 =A0 =A0| =A0 =
=A00
> =A0drivers/net/{ =3D> ethernet}/enic/enic_dev.c =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/enic_dev.h =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/enic_main.c =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/enic_pp.c =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/enic_pp.h =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/enic_res.c =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/enic_res.h =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/rq_enet_desc.h =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/vnic_cq.c =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/vnic_cq.h =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/vnic_dev.c =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/vnic_dev.h =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/vnic_devcmd.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/vnic_enet.h =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/vnic_intr.c =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/vnic_intr.h =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/vnic_nic.h =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/vnic_resource.h | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/vnic_rq.c =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/vnic_rq.h =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/vnic_rss.h =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/vnic_stats.h =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/vnic_vic.c =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/vnic_vic.h =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/vnic_wq.c =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/vnic_wq.h =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/enic/wq_enet_desc.h =A0| =A0 =A00
> =A037 files changed, 12 insertions(+), 8 deletions(-)
>
> commit 21b49617eef3976ebbd73cb4bf1a1f2f6902dbbf
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Fri May 13 14:29:12 2011 -0700
>
> =A0 =A0ehea/ibm*: Move the IBM drivers
>
> =A0 =A0Move the IBM drivers into drivers/net/ethernet/ibm/ and make t=
he
> =A0 =A0necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Christoph Raisch <raisch@de.ibm.com>
> =A0 =A0CC: Alfred Arnold <alfred.arnold@lancom.de>
> =A0 =A0CC: Santiago Leon <santil@linux.vnet.ibm.com>
> =A0 =A0CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0| =A0 37 --------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 | =A0 =A04 --
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0| =A0 =A01 +
> =A0drivers/net/ethernet/ibm/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 | =A0 53 ++++++++++++++++++++
> =A0drivers/net/ethernet/ibm/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0| =A0 =A08 +++
> =A0drivers/net/{ =3D> ethernet/ibm}/ehea/Makefile =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/ibm}/ehea/ehea.h =A0 =A0 =A0 =A0 | =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet/ibm}/ehea/ehea_ethtool.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/ibm}/ehea/ehea_hw.h =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/ibm}/ehea/ehea_main.c =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/ibm}/ehea/ehea_phyp.c =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/ibm}/ehea/ehea_phyp.h =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/ibm}/ehea/ehea_qmr.c =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/ibm}/ehea/ehea_qmr.h =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/Kconfig | =A0 =A02 +-
> =A0.../net/{ =3D> ethernet/ibm}/ibm_newemac/Makefile =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/core.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/core.h =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/debug.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/debug.h | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/emac.h =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/mal.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/mal.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/phy.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/phy.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/rgmii.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/rgmii.h | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/tah.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/tah.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/zmii.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/ibm}/ibm_newemac/zmii.h =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/ibm}/ibmlana.c =A0 =A0 =A0 =A0 =A0 | =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet/ibm}/ibmlana.h =A0 =A0 =A0 =A0 =A0 | =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet/ibm}/ibmveth.c =A0 =A0 =A0 =A0 =A0 | =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet/ibm}/ibmveth.h =A0 =A0 =A0 =A0 =A0 | =A0=
 =A00
> =A037 files changed, 66 insertions(+), 44 deletions(-)
>
> commit a5c1daab860bc137dafadc061e48f4153ce89a31
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Fri May 13 02:51:01 2011 -0700
>
> =A0 =A0s2io/vxge: Move the Exar drivers
>
> =A0 =A0Move the Exar drivers into drivers/net/ethernet/exar/ and make=
 the
> =A0 =A0necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Jon Mason <jdmason@kudzu.us>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A03 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0| =A0 34 -------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 | =A0 =A02 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0| =A0 =A01 +
> =A0drivers/net/ethernet/exar/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0| =A0 50 ++++++++++++++++++++
> =A0drivers/net/ethernet/exar/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 | =A0 =A06 ++
> =A0drivers/net/{ =3D> ethernet/exar}/s2io-regs.h =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet/exar}/s2io.c =A0 =A0 =A0 =A0 =A0 =A0 |=
 =A0 =A00
> =A0drivers/net/{ =3D> ethernet/exar}/s2io.h =A0 =A0 =A0 =A0 =A0 =A0 |=
 =A0 =A00
> =A0drivers/net/{ =3D> ethernet/exar}/vxge/Makefile =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/exar}/vxge/vxge-config.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/exar}/vxge/vxge-config.h | =A0 =A00
> =A0.../net/{ =3D> ethernet/exar}/vxge/vxge-ethtool.c =A0 =A0| =A0 =A0=
0
> =A0.../net/{ =3D> ethernet/exar}/vxge/vxge-ethtool.h =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/exar}/vxge/vxge-main.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/exar}/vxge/vxge-main.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/exar}/vxge/vxge-reg.h =A0 =A0| =A0 =A0=
0
> =A0.../net/{ =3D> ethernet/exar}/vxge/vxge-traffic.c =A0 =A0| =A0 =A0=
0
> =A0.../net/{ =3D> ethernet/exar}/vxge/vxge-traffic.h =A0 =A0| =A0 =A0=
0
> =A0.../net/{ =3D> ethernet/exar}/vxge/vxge-version.h =A0 =A0| =A0 =A0=
0
> =A021 files changed, 59 insertions(+), 38 deletions(-)
>
> commit 83df87d655e25119eafaeb4225bc5eedaa82c6e0
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Fri May 13 02:24:46 2011 -0700
>
> =A0 =A0myri*: Move the Myricom drivers
>
> =A0 =A0Move the Myricom drivers into drivers/net/ethernet/myricom/ an=
d make
> =A0 =A0the necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Andrew Gallatin <gallatin@myri.com>
> =A0 =A0CC: Brice Goglin <brice@myri.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0| =A0 35 -------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 | =A0 =A03 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0| =A0 =A01 +
> =A0drivers/net/ethernet/myricom/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 |=
 =A0 51 ++++++++++++++++++++
> =A0drivers/net/ethernet/myricom/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 =A06 ++
> =A0.../net/{ =3D> ethernet/myricom}/myri10ge/Makefile =A0 | =A0 =A00
> =A0.../net/{ =3D> ethernet/myricom}/myri10ge/myri10ge.c | =A0 =A00
> =A0.../{ =3D> ethernet/myricom}/myri10ge/myri10ge_mcp.h | =A0 =A00
> =A0.../myricom}/myri10ge/myri10ge_mcp_gen_header.h =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/myricom}/myri_sbus.c =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/myricom}/myri_sbus.h =A0 =A0 | =A0 =A0=
0

/me puts on Myricom hat

I believe we want to put the driver above in the sbus/legacy
directory.  Better yet, move this driver to /dev/null.  There is no
possibility of ethernet mode on this adapter, so it's Myrinet only.
It won't inter-op with modern versions of Myrinet, and thus can only
work with legacy adapters.  There are no drivers for the PCI version
of this adapter, so it only can work on ~15year old hardware.  It's
long in the tooth, let's take it to the knackers.

Thanks,
Jon

> =A013 files changed, 60 insertions(+), 39 deletions(-)
>
> commit c04bd079e4ab82c5ee8fd0cb526f16e9ffce9360
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Fri May 13 01:32:22 2011 -0700
>
> =A0 =A0mlx4: Move the Mellanox driver
>
> =A0 =A0Moves the Mellanox driver into drivers/net/ethernet/mlx4/ and =
make
> =A0 =A0the necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Roland Dreier <roland@kernel.org>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0| =A0 24 ---------------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A01 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 |=
 =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 =A01 +
> =A0drivers/net/ethernet/mlx4/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 27 ++++++++++++++++++++++++
> =A0drivers/net/{ =3D> ethernet}/mlx4/Makefile =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/mlx4/alloc.c =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/mlx4/catas.c =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/mlx4/cmd.c =A0 =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/mlx4/cq.c =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/mlx4/en_cq.c =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/mlx4/en_ethtool.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/mlx4/en_main.c =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/mlx4/en_netdev.c =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/mlx4/en_port.c =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/mlx4/en_port.h =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/mlx4/en_resources.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/mlx4/en_rx.c =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/mlx4/en_selftest.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/mlx4/en_tx.c =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/mlx4/eq.c =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/mlx4/fw.c =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/mlx4/fw.h =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/mlx4/icm.c =A0 =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/mlx4/icm.h =A0 =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/mlx4/intf.c =A0 =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/mlx4/main.c =A0 =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/mlx4/mcg.c =A0 =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/mlx4/mlx4.h =A0 =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/mlx4/mlx4_en.h =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/mlx4/mr.c =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/mlx4/pd.c =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/mlx4/port.c =A0 =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/mlx4/profile.c =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/mlx4/qp.c =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/mlx4/reset.c =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/mlx4/sense.c =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/mlx4/srq.c =A0 =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A038 files changed, 29 insertions(+), 25 deletions(-)
>
> commit d911fd7be681f8833f8ff12efade39df79970653
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Fri May 13 01:00:03 2011 -0700
>
> =A0 =A0bna: Move the Brocade driver
>
> =A0 =A0Moves the Brocade driver into drivers/net/ethernet/bna/ and ma=
ke
> =A0 =A0the necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Rasesh Mody <rmody@brocade.com>
> =A0 =A0CC: Debashis Dutt <ddutt@brocade.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0| =A0 14 --------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 | =A0 =A01 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0| =A0 =A01 +
> =A0drivers/net/ethernet/bna/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 | =A0 17 +++++++++++++++++
> =A0drivers/net/{ =3D> ethernet}/bna/Makefile =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/bna/bfa_cee.c =A0 =A0 =A0 =A0 =A0 | =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/bna/bfa_cee.h =A0 =A0 =A0 =A0 =A0 | =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/bna/bfa_defs.h =A0 =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/bna/bfa_defs_cna.h =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/bna/bfa_defs_mfg_comm.h | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/bna/bfa_defs_status.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/bna/bfa_ioc.c =A0 =A0 =A0 =A0 =A0 | =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/bna/bfa_ioc.h =A0 =A0 =A0 =A0 =A0 | =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/bna/bfa_ioc_ct.c =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/bna/bfa_sm.h =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/bna/bfa_wc.h =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/bna/bfi.h =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/bna/bfi_cna.h =A0 =A0 =A0 =A0 =A0 | =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/bna/bfi_ctreg.h =A0 =A0 =A0 =A0 | =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/bna/bfi_ll.h =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/bna/bna.h =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/bna/bna_ctrl.c =A0 =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/bna/bna_hw.h =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/bna/bna_txrx.c =A0 =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/bna/bna_types.h =A0 =A0 =A0 =A0 | =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/bna/bnad.c =A0 =A0 =A0 =A0 =A0 =A0 =A0=
| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/bna/bnad.h =A0 =A0 =A0 =A0 =A0 =A0 =A0=
| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/bna/bnad_ethtool.c =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/bna/cna.h =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/bna/cna_fwimg.c =A0 =A0 =A0 =A0 | =A0=
 =A00
> =A032 files changed, 20 insertions(+), 16 deletions(-)
>
> commit 931da59411e60574a1235d0ad2d63ebd1638a859
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Fri May 13 00:37:27 2011 -0700
>
> =A0 =A0be2net: Move the BladeEngine 2 driver
>
> =A0 =A0Moves the Server Engine driver into drivers/net/ethernet/benet=
/ and
> =A0 =A0make the necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Sathya Perla <sathya.perla@emulex.com>
> =A0 =A0CC: Subbu Seetharaman <subbu.seetharaman@emulex.com>
> =A0 =A0CC: Ajit Khaparde <ajit.khaparde@emulex.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 | =A0 =A02 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A02 --
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0| =A0 =A01 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =
=A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A01 +
> =A0drivers/net/{ =3D> ethernet}/benet/Kconfig =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/benet/Makefile =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/benet/be.h =A0 =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/benet/be_cmds.c =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/benet/be_cmds.h =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/benet/be_ethtool.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/benet/be_hw.h =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/benet/be_main.c =A0 =A0| =A0 =A00
> =A013 files changed, 3 insertions(+), 4 deletions(-)
>
> commit 64648e513185522cd665bfece6d024d3c05588ed
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Fri May 13 00:17:42 2011 -0700
>
> =A0 =A0sfc: Move the Solarflare drivers
>
> =A0 =A0Moves the Solarflare drivers into drivers/net/ethernet/sfc/ an=
d
> =A0 =A0make the necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Steve Hodgson <shodgson@solarflare.com>
> =A0 =A0CC: Ben Hutchings <bhutchings@solarflare.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0| =A0 =A02 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0| =A0 =A02 --
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A01 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 |=
 =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 =A01 +
> =A0drivers/net/{ =3D> ethernet}/sfc/Kconfig =A0 =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/sfc/Makefile =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/sfc/bitfield.h =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/sfc/efx.c =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/sfc/efx.h =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/sfc/enum.h =A0 =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/sfc/ethtool.c =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/sfc/falcon.c =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/sfc/falcon_boards.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/sfc/falcon_xmac.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/sfc/filter.c =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/sfc/filter.h =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/sfc/io.h =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/sfc/mac.h =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/sfc/mcdi.c =A0 =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/sfc/mcdi.h =A0 =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/sfc/mcdi_mac.c =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/sfc/mcdi_pcol.h =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/sfc/mcdi_phy.c =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/sfc/mdio_10g.c =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/sfc/mdio_10g.h =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/sfc/mtd.c =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/sfc/net_driver.h =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/sfc/nic.c =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/sfc/nic.h =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/sfc/phy.h =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/sfc/qt202x_phy.c =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/sfc/regs.h =A0 =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/sfc/rx.c =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/sfc/selftest.c =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/sfc/selftest.h =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/sfc/siena.c =A0 =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/sfc/spi.h =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet}/sfc/tenxpress.c =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/sfc/tx.c =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet}/sfc/txc43128_phy.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet}/sfc/workarounds.h =A0 | =A0 =A00
> =A042 files changed, 3 insertions(+), 4 deletions(-)
>
> commit a9f8e9475d4f7c91880050634e923d62e369a0ed
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Thu May 12 23:04:46 2011 -0700
>
> =A0 =A0cassini/niu/sun*: Move the Sun drivers
>
> =A0 =A0Moves the Sun drivers into drivers/net/ethernet/sun/ and make
> =A0 =A0the necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Sam Creasey <sammy@sammy.net>
> =A0 =A0CC: Adrian Sun <asun@darksunrising.com>
> =A0 =A0CC: Benjamin Herrenscmidt <benh@kernel.crashing.org>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 | =A0 =A01 +
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 | =A0 75 ----------------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
| =A0 10 +---
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =
=A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
1 +
> =A0drivers/net/ethernet/sun/Kconfig =A0 =A0 =A0 =A0 =A0 =A0| =A0 91 +=
++++++++++++++++++++++++++
> =A0drivers/net/ethernet/sun/Makefile =A0 =A0 =A0 =A0 =A0 | =A0 12 +++=
+
> =A0drivers/net/{ =3D> ethernet/sun}/cassini.c =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/sun}/cassini.h =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/sun}/niu.c =A0 =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/sun}/niu.h =A0 =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/sun}/sun3_82586.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/sun}/sun3_82586.h | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/sun}/sunbmac.c =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/sun}/sunbmac.h =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/sun}/sungem.c =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/sun}/sungem.h =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/sun}/sungem_phy.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/sun}/sungem_phy.h | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/sun}/sunhme.c =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/sun}/sunhme.h =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/sun}/sunqe.c =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/sun}/sunqe.h =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/sun}/sunvnet.c =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/sun}/sunvnet.h =A0 =A0| =A0 =A00
> =A0drivers/net/spider_net.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =
=A0 =A02 +-
> =A026 files changed, 108 insertions(+), 85 deletions(-)
>
> commit c1b4800864efcbacb0f02047609b41c9ab5290e6
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Thu May 12 21:21:33 2011 -0700
>
> =A0 =A0ni5*/ni65: Move the Racal-Interlan (Micom) drivers
>
> =A0 =A0Moves the Racal-Interlan drivers into drivers/net/ethernet/rac=
al/ and
> =A0 =A0make the necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: "Jan-Pascal van Best" <janpascal@vanbest.org>
> =A0 =A0CC: Andreas Mohr <andi@lisas.de>
> =A0 =A0CC: "M.Hipp" <hippm@informatik.uni-tuebingen.de>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A02 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =
=A0 47 ---------------------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =
=A0 =A03 --
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01=
 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0drivers/net/ethernet/racal/Kconfig =A0 =A0 =A0 =A0| =A0 50 +++++++=
++++++++++++++++++++++
> =A0drivers/net/ethernet/racal/Makefile =A0 =A0 =A0 | =A0 =A07 ++++
> =A0drivers/net/{ =3D> ethernet/racal}/ni5010.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/racal}/ni5010.h | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/racal}/ni52.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/racal}/ni52.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/racal}/ni65.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/racal}/ni65.h =A0 | =A0 =A00
> =A013 files changed, 60 insertions(+), 51 deletions(-)
>
> commit 671dc5b8fb145ff8748cdc2aeffd1ef56af8bd67
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Thu May 12 20:21:07 2011 -0700
>
> =A0 =A0smc: Move the SMC drivers
>
> =A0 =A0Moves the SMC drivers into drivers/net/ethernet/smc/ and the
> =A0 =A0necessary Kconfig and Makefile changes. =A0Also did some clean=
up
> =A0 =A0of NET_VENDOR_SMC Kconfig tag for the 8390 based drivers.
>
> =A0 =A0CC: Nicolas Pitre <nico@fluxnic.net>
> =A0 =A0CC: Donald Becker <becker@scyld.com>
> =A0 =A0CC: Erik Stahlman <erik@vt.edu>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0| =A0 =A02 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 51 -------------------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A04 --
> =A0drivers/net/ethernet/8390/Kconfig =A0 =A0 =A0 =A0| =A0 21 ++------=
--
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
> =A0drivers/net/ethernet/qlogic/Kconfig =A0 =A0 =A0| =A0 =A07 +++
> =A0drivers/net/ethernet/qlogic/Makefile =A0 =A0 | =A0 =A01 +
> =A0drivers/net/ethernet/smc/Kconfig =A0 =A0 =A0 =A0 | =A0 61 ++++++++=
++++++++++++++++++++++
> =A0drivers/net/ethernet/smc/Makefile =A0 =A0 =A0 =A0| =A0 =A07 +++
> =A0drivers/net/{ =3D> ethernet/smc}/epic100.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/smc}/smc9194.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/smc}/smc9194.h | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/smc}/smc91x.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/smc}/smc91x.h =A0| =A0 =A00
> =A015 files changed, 83 insertions(+), 73 deletions(-)
>
> commit e9f8a5c9b5f8f469bcfae06ddd10e9dc9537f7bb
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Fri Apr 8 19:06:30 2011 -0700
>
> =A0 =A0qlogic: Move the QLogic drivers
>
> =A0 =A0Moves the QLogic drivers into drivers/net/ethernet/qlogic/ and
> =A0 =A0the necessary Kconfig and Makefile changes.
>
> =A0 =A0CC: Ron Mercer <ron.mercer@qlogic.com>
> =A0 =A0CC: Amit Kumar Salecha <amit.salecha@qlogic.com>
> =A0 =A0CC: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A06 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0| =A0 26 ------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 | =A0 =A03 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0| =A0 =A01 +
> =A0drivers/net/ethernet/qlogic/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
| =A0 42 ++++++++++++++++++++
> =A0drivers/net/ethernet/qlogic/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 |=
 =A0 =A07 +++
> =A0drivers/net/{ =3D> ethernet/qlogic}/netxen/Makefile =A0| =A0 =A00
> =A0.../net/{ =3D> ethernet/qlogic}/netxen/netxen_nic.h =A0| =A0 =A00
> =A0.../{ =3D> ethernet/qlogic}/netxen/netxen_nic_ctx.c =A0| =A0 =A00
> =A0.../qlogic}/netxen/netxen_nic_ethtool.c =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0.../{ =3D> ethernet/qlogic}/netxen/netxen_nic_hdr.h =A0| =A0 =A00
> =A0.../{ =3D> ethernet/qlogic}/netxen/netxen_nic_hw.c =A0 | =A0 =A00
> =A0.../{ =3D> ethernet/qlogic}/netxen/netxen_nic_hw.h =A0 | =A0 =A00
> =A0.../{ =3D> ethernet/qlogic}/netxen/netxen_nic_init.c | =A0 =A00
> =A0.../{ =3D> ethernet/qlogic}/netxen/netxen_nic_main.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/qlogic}/qla3xxx.c =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet/qlogic}/qla3xxx.h =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet/qlogic}/qlcnic/Makefile =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/qlogic}/qlcnic/qlcnic.h =A0| =A0 =A00
> =A0.../net/{ =3D> ethernet/qlogic}/qlcnic/qlcnic_ctx.c =A0| =A0 =A00
> =A0.../{ =3D> ethernet/qlogic}/qlcnic/qlcnic_ethtool.c =A0| =A0 =A00
> =A0.../net/{ =3D> ethernet/qlogic}/qlcnic/qlcnic_hdr.h =A0| =A0 =A00
> =A0.../net/{ =3D> ethernet/qlogic}/qlcnic/qlcnic_hw.c =A0 | =A0 =A00
> =A0.../net/{ =3D> ethernet/qlogic}/qlcnic/qlcnic_init.c | =A0 =A00
> =A0.../net/{ =3D> ethernet/qlogic}/qlcnic/qlcnic_main.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/qlogic}/qlge/Makefile =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/qlogic}/qlge/qlge.h =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/qlogic}/qlge/qlge_dbg.c =A0| =A0 =A00
> =A0.../net/{ =3D> ethernet/qlogic}/qlge/qlge_ethtool.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/qlogic}/qlge/qlge_main.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/qlogic}/qlge/qlge_mpi.c =A0| =A0 =A00
> =A032 files changed, 54 insertions(+), 32 deletions(-)
>
> commit f8e68b0056ef20887bdfdc31ff061d67e81308e2
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Thu Apr 7 07:42:33 2011 -0700
>
> =A0 =A0intel: Move the Intel wired LAN drivers
>
> =A0 =A0Moves the Intel wired LAN drivers into drivers/net/ethernet/in=
tel/ and
> =A0 =A0the necessary Kconfig and Makefile changes.
>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0| =A0 11 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0| =A0200 ------------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 | =A0 =A08 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0| =A0 =A01 +
> =A0drivers/net/ethernet/intel/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 | =A0216 ++++++++++++++++++++
> =A0drivers/net/ethernet/intel/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
| =A0 12 +
> =A0drivers/net/{ =3D> ethernet/intel}/e100.c =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/e1000/Makefile =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/e1000/e1000.h =A0 =A0 | =A0 =A0=
0
> =A0.../net/{ =3D> ethernet/intel}/e1000/e1000_ethtool.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/e1000/e1000_hw.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/e1000/e1000_hw.h =A0| =A0 =A00
> =A0.../net/{ =3D> ethernet/intel}/e1000/e1000_main.c =A0 =A0| =A0 =A0=
0
> =A0.../net/{ =3D> ethernet/intel}/e1000/e1000_osdep.h =A0 | =A0 =A00
> =A0.../net/{ =3D> ethernet/intel}/e1000/e1000_param.c =A0 | =A0 =A00
> =A0.../intel/e1000e/80003es2lan.c} =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/e1000e/82571.c =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/e1000e/Makefile =A0 | =A0 =A02 =
+-
> =A0drivers/net/{ =3D> ethernet/intel}/e1000e/defines.h =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/e1000e/e1000.h =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/e1000e/ethtool.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/e1000e/hw.h =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/e1000e/ich8lan.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/e1000e/lib.c =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/e1000e/netdev.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/e1000e/param.c =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/e1000e/phy.c =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/igb/Makefile =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/igb/e1000_82575.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/igb/e1000_82575.h | =A0 =A00
> =A0.../net/{ =3D> ethernet/intel}/igb/e1000_defines.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/igb/e1000_hw.h =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/igb/e1000_mac.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/igb/e1000_mac.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/igb/e1000_mbx.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/igb/e1000_mbx.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/igb/e1000_nvm.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/igb/e1000_nvm.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/igb/e1000_phy.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/igb/e1000_phy.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/igb/e1000_regs.h =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/igb/igb.h =A0 =A0 =A0 =A0 | =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/igb/igb_ethtool.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/igb/igb_main.c =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/igbvf/Makefile =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/igbvf/defines.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/igbvf/ethtool.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/igbvf/igbvf.h =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/igbvf/mbx.c =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/igbvf/mbx.h =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/igbvf/netdev.c =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/igbvf/regs.h =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/igbvf/vf.c =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/igbvf/vf.h =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/ixgb/Makefile =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/ixgb/ixgb.h =A0 =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/ixgb/ixgb_ee.c =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/ixgb/ixgb_ee.h =A0 =A0| =A0 =A0=
0
> =A0.../net/{ =3D> ethernet/intel}/ixgb/ixgb_ethtool.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/ixgb/ixgb_hw.c =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/ixgb/ixgb_hw.h =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/ixgb/ixgb_ids.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/ixgb/ixgb_main.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/ixgb/ixgb_osdep.h | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/ixgb/ixgb_param.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/ixgbe/Makefile =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/ixgbe/ixgbe.h =A0 =A0 | =A0 =A0=
0
> =A0.../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_82598.c =A0 | =A0 =A00
> =A0.../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_82599.c =A0 | =A0 =A00
> =A0.../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_common.c =A0| =A0 =A00
> =A0.../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_common.h =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/ixgbe/ixgbe_dcb.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/ixgbe/ixgbe_dcb.h | =A0 =A00
> =A0.../{ =3D> ethernet/intel}/ixgbe/ixgbe_dcb_82598.c =A0 | =A0 =A00
> =A0.../{ =3D> ethernet/intel}/ixgbe/ixgbe_dcb_82598.h =A0 | =A0 =A00
> =A0.../{ =3D> ethernet/intel}/ixgbe/ixgbe_dcb_82599.c =A0 | =A0 =A00
> =A0.../{ =3D> ethernet/intel}/ixgbe/ixgbe_dcb_82599.h =A0 | =A0 =A00
> =A0.../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_dcb_nl.c =A0| =A0 =A00
> =A0.../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_ethtool.c | =A0 =A00
> =A0.../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_fcoe.c =A0 =A0| =A0 =A0=
0
> =A0.../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_fcoe.h =A0 =A0| =A0 =A0=
0
> =A0.../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_main.c =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/ixgbe/ixgbe_mbx.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/ixgbe/ixgbe_mbx.h | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/ixgbe/ixgbe_phy.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/ixgbe/ixgbe_phy.h | =A0 =A00
> =A0.../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_sriov.c =A0 | =A0 =A00
> =A0.../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_sriov.h =A0 | =A0 =A00
> =A0.../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_type.h =A0 =A0| =A0 =A0=
0
> =A0.../net/{ =3D> ethernet/intel}/ixgbe/ixgbe_x540.c =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/ixgbevf/Makefile =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/ixgbevf/defines.h | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/ixgbevf/ethtool.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/intel}/ixgbevf/ixgbevf.h | =A0 =A00
> =A0.../{ =3D> ethernet/intel}/ixgbevf/ixgbevf_main.c =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/ixgbevf/mbx.c =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/ixgbevf/mbx.h =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/ixgbevf/regs.h =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/ixgbevf/vf.c =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/intel}/ixgbevf/vf.h =A0 =A0 =A0| =A0 =A0=
0
> =A0101 files changed, 233 insertions(+), 218 deletions(-)
>
> commit e9518ae90966c061c0efa161e885ba23bda6c0a8
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Thu Apr 7 06:57:17 2011 -0700
>
> =A0 =A0chelsio: Move the Chelsio drivers
>
> =A0 =A0Moves the drivers for the Chelsio chipsets into
> =A0 =A0drivers/net/ethernet/chelsio/ and the necessary Kconfig and Ma=
kefile
> =A0 =A0changes.
>
> =A0 =A0CC: Divy Le Ray <divy@chelsio.com>
> =A0 =A0CC: Dimitris Michailidis <dm@chelsio.com>
> =A0 =A0CC: Casey Leedom <leedom@chelsio.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A06 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0| =A0 86 ----------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 | =A0 =A04 -
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0| =A0 =A01 +
> =A0drivers/net/ethernet/chelsio/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 |=
 =A0102 ++++++++++++++++++++
> =A0drivers/net/ethernet/chelsio/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 =A08 ++
> =A0.../{chelsio =3D> ethernet/chelsio/cxgb}/Makefile =A0 =A0| =A0 =A0=
0
> =A0.../{chelsio =3D> ethernet/chelsio/cxgb}/common.h =A0 =A0| =A0 =A0=
0
> =A0.../net/{chelsio =3D> ethernet/chelsio/cxgb}/cphy.h =A0| =A0 =A00
> =A0.../{chelsio =3D> ethernet/chelsio/cxgb}/cpl5_cmd.h =A0| =A0 =A00
> =A0.../net/{chelsio =3D> ethernet/chelsio/cxgb}/cxgb2.c | =A0 =A00
> =A0.../{chelsio =3D> ethernet/chelsio/cxgb}/elmer0.h =A0 =A0| =A0 =A0=
0
> =A0.../net/{chelsio =3D> ethernet/chelsio/cxgb}/espi.c =A0| =A0 =A00
> =A0.../net/{chelsio =3D> ethernet/chelsio/cxgb}/espi.h =A0| =A0 =A00
> =A0.../{chelsio =3D> ethernet/chelsio/cxgb}/fpga_defs.h | =A0 =A00
> =A0.../net/{chelsio =3D> ethernet/chelsio/cxgb}/gmac.h =A0| =A0 =A00
> =A0.../{chelsio =3D> ethernet/chelsio/cxgb}/mv88e1xxx.c | =A0 =A00
> =A0.../{chelsio =3D> ethernet/chelsio/cxgb}/mv88e1xxx.h | =A0 =A00
> =A0.../{chelsio =3D> ethernet/chelsio/cxgb}/mv88x201x.c | =A0 =A00
> =A0.../{chelsio =3D> ethernet/chelsio/cxgb}/my3126.c =A0 =A0| =A0 =A0=
0
> =A0.../{chelsio =3D> ethernet/chelsio/cxgb}/pm3393.c =A0 =A0| =A0 =A0=
0
> =A0.../net/{chelsio =3D> ethernet/chelsio/cxgb}/regs.h =A0| =A0 =A00
> =A0.../net/{chelsio =3D> ethernet/chelsio/cxgb}/sge.c =A0 | =A0 =A00
> =A0.../net/{chelsio =3D> ethernet/chelsio/cxgb}/sge.h =A0 | =A0 =A00
> =A0.../net/{chelsio =3D> ethernet/chelsio/cxgb}/subr.c =A0| =A0 =A00
> =A0.../chelsio/cxgb}/suni1x10gexp_regs.h =A0 =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 =A00
> =A0.../net/{chelsio =3D> ethernet/chelsio/cxgb}/tp.c =A0 =A0| =A0 =A0=
0
> =A0.../net/{chelsio =3D> ethernet/chelsio/cxgb}/tp.h =A0 =A0| =A0 =A0=
0
> =A0.../{chelsio =3D> ethernet/chelsio/cxgb}/vsc7326.c =A0 | =A0 =A00
> =A0.../chelsio/cxgb}/vsc7326_reg.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb3/Makefile =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb3/adapter.h | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb3/ael1002.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb3/aq100x.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb3/common.h =A0| =A0 =A00
> =A0.../{ =3D> ethernet/chelsio}/cxgb3/cxgb3_ctl_defs.h =A0| =A0 =A00
> =A0.../net/{ =3D> ethernet/chelsio}/cxgb3/cxgb3_defs.h =A0| =A0 =A00
> =A0.../net/{ =3D> ethernet/chelsio}/cxgb3/cxgb3_ioctl.h | =A0 =A00
> =A0.../net/{ =3D> ethernet/chelsio}/cxgb3/cxgb3_main.c =A0| =A0 =A00
> =A0.../{ =3D> ethernet/chelsio}/cxgb3/cxgb3_offload.c =A0 | =A0 =A00
> =A0.../{ =3D> ethernet/chelsio}/cxgb3/cxgb3_offload.h =A0 | =A0 =A00
> =A0.../chelsio}/cxgb3/firmware_exports.h =A0 =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 =A00
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb3/l2t.c =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb3/l2t.h =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb3/mc5.c =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb3/regs.h =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb3/sge.c =A0 =A0 | =A0 =A0=
0
> =A0.../net/{ =3D> ethernet/chelsio}/cxgb3/sge_defs.h =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb3/t3_cpl.h =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb3/t3_hw.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb3/t3cdev.h =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb3/version.h | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb3/vsc8211.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb3/xgmac.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb4/Makefile =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb4/cxgb4.h =A0 | =A0 =A00
> =A0.../net/{ =3D> ethernet/chelsio}/cxgb4/cxgb4_main.c =A0| =A0 =A00
> =A0.../net/{ =3D> ethernet/chelsio}/cxgb4/cxgb4_uld.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb4/l2t.c =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb4/l2t.h =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb4/sge.c =A0 =A0 | =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb4/t4_hw.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb4/t4_hw.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb4/t4_msg.h =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb4/t4_regs.h | =A0 =A00
> =A0.../net/{ =3D> ethernet/chelsio}/cxgb4/t4fw_api.h =A0 =A0| =A0 =A0=
0
> =A0.../net/{ =3D> ethernet/chelsio}/cxgb4vf/Makefile =A0 =A0| =A0 =A0=
0
> =A0.../net/{ =3D> ethernet/chelsio}/cxgb4vf/adapter.h =A0 | =A0 =A00
> =A0.../{ =3D> ethernet/chelsio}/cxgb4vf/cxgb4vf_main.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/chelsio}/cxgb4vf/sge.c =A0 | =A0 =A00
> =A0.../{ =3D> ethernet/chelsio}/cxgb4vf/t4vf_common.h =A0 | =A0 =A00
> =A0.../net/{ =3D> ethernet/chelsio}/cxgb4vf/t4vf_defs.h | =A0 =A00
> =A0.../net/{ =3D> ethernet/chelsio}/cxgb4vf/t4vf_hw.c =A0 | =A0 =A00
> =A074 files changed, 115 insertions(+), 93 deletions(-)
>
> commit 1e954aa058cd1496b47b914878509e9ecf136d05
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Thu Apr 7 06:03:04 2011 -0700
>
> =A0 =A0broadcom: Move the Broadcom drivers
>
> =A0 =A0Moves the drivers for Broadcom devices into
> =A0 =A0drivers/net/ethernet/broadcom/ and the necessary Kconfig and M=
akefile
> =A0 =A0changes.
>
> =A0 =A0CC: Eilon Greenstein <eilong@broadcom.com>
> =A0 =A0CC: Michael Chan <mchan@broadcom.com>
> =A0 =A0CC: Matt Carlson <mcarlson@broadcom.com>
> =A0 =A0CC: Gary Zambrano <zambrano@broadcom.com>
> =A0 =A0CC: "Maciej W. Rozycki" <macro@linux-mips.org>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0| =A0 10 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0| =A0 99 -----------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 | =A0 =A07 --
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0| =A0 =A01 +
> =A0drivers/net/ethernet/broadcom/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0114 ++++++++++++++++++++
> =A0drivers/net/ethernet/broadcom/Makefile =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 11 ++
> =A0drivers/net/{ =3D> ethernet/broadcom}/b44.c =A0 =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet/broadcom}/b44.h =A0 =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet/broadcom}/bcm63xx_enet.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/broadcom}/bcm63xx_enet.h | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/broadcom}/bnx2.c =A0 =A0 =A0 =A0 | =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet/broadcom}/bnx2.h =A0 =A0 =A0 =A0 | =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet/broadcom}/bnx2_fw.h =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/broadcom}/bnx2x/Makefile | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/broadcom}/bnx2x/bnx2x.h =A0| =A0 =A00
> =A0.../net/{ =3D> ethernet/broadcom}/bnx2x/bnx2x_cmn.c =A0| =A0 =A00
> =A0.../net/{ =3D> ethernet/broadcom}/bnx2x/bnx2x_cmn.h =A0| =A0 =A00
> =A0.../net/{ =3D> ethernet/broadcom}/bnx2x/bnx2x_dcb.c =A0| =A0 =A00
> =A0.../net/{ =3D> ethernet/broadcom}/bnx2x/bnx2x_dcb.h =A0| =A0 =A00
> =A0.../net/{ =3D> ethernet/broadcom}/bnx2x/bnx2x_dump.h | =A0 =A00
> =A0.../{ =3D> ethernet/broadcom}/bnx2x/bnx2x_ethtool.c =A0| =A0 =A00
> =A0.../{ =3D> ethernet/broadcom}/bnx2x/bnx2x_fw_defs.h =A0| =A0 =A00
> =A0.../broadcom}/bnx2x/bnx2x_fw_file_hdr.h =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0.../net/{ =3D> ethernet/broadcom}/bnx2x/bnx2x_hsi.h =A0| =A0 =A00
> =A0.../net/{ =3D> ethernet/broadcom}/bnx2x/bnx2x_init.h | =A0 =A00
> =A0.../{ =3D> ethernet/broadcom}/bnx2x/bnx2x_init_ops.h | =A0 =A00
> =A0.../net/{ =3D> ethernet/broadcom}/bnx2x/bnx2x_link.c | =A0 =A00
> =A0.../net/{ =3D> ethernet/broadcom}/bnx2x/bnx2x_link.h | =A0 =A00
> =A0.../net/{ =3D> ethernet/broadcom}/bnx2x/bnx2x_main.c | =A0 =A00
> =A0.../net/{ =3D> ethernet/broadcom}/bnx2x/bnx2x_reg.h =A0| =A0 =A00
> =A0.../{ =3D> ethernet/broadcom}/bnx2x/bnx2x_stats.c =A0 =A0| =A0 =A0=
0
> =A0.../{ =3D> ethernet/broadcom}/bnx2x/bnx2x_stats.h =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/broadcom}/cnic.c =A0 =A0 =A0 =A0 | =A0=
 =A04 +-
> =A0drivers/net/{ =3D> ethernet/broadcom}/cnic.h =A0 =A0 =A0 =A0 | =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet/broadcom}/cnic_defs.h =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/broadcom}/cnic_if.h =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/broadcom}/sb1250-mac.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/broadcom}/tg3.c =A0 =A0 =A0 =A0 =A0| =A0=
 =A00
> =A0drivers/net/{ =3D> ethernet/broadcom}/tg3.h =A0 =A0 =A0 =A0 =A0| =A0=
 =A00
> =A040 files changed, 134 insertions(+), 113 deletions(-)
>
> commit 29072561a23c3802112a94fa0a9383773056f19a
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Sat Apr 2 06:20:12 2011 -0700
>
> =A0 =A08390: Move the 8390 related drivers
>
> =A0 =A0Moves the drivers for the National Semi-conductor 8390 chipset=
 into
> =A0 =A0drivers/net/ethernet/8390/ and the necessary Kconfig and Makef=
ile
> =A0 =A0changes.
>
> =A0 =A0CC: Donald Becker <becker@scyld.com>
> =A0 =A0CC: Paul Gortmaker <paul.gortmaker@windriver.com>
> =A0 =A0CC: Alain Malek <alain.malek@cryogen.com>
> =A0 =A0CC: Peter De Schrijver <p2@mind.be>
> =A0 =A0CC: "David Huggins-Daines" <dhd@debian.org>
> =A0 =A0CC: Wim Dumon <wimpie@kotnet.org>
> =A0 =A0CC: Yoshinori Sato <ysato@users.sourceforge.jp>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 | =A0 =A05 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0283 -----------------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0| =A0 22 --
> =A0drivers/net/ethernet/3com/Makefile =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0=
2 +-
> =A0drivers/net/{ =3D> ethernet/8390}/8390.c =A0 =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/8390}/8390.h =A0 =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/8390}/8390p.c =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/ethernet/8390/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 | =A0301=
 +++++++++++++++++++++++++
> =A0drivers/net/ethernet/8390/Makefile =A0 =A0 =A0 =A0 =A0 =A0| =A0 26=
 +++
> =A0drivers/net/{ =3D> ethernet/8390}/ac3200.c =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/8390}/apne.c =A0 =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/8390}/ax88796.c =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/8390}/e2100.c =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/8390}/es3210.c =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/8390}/hp-plus.c =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/8390}/hp.c =A0 =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/8390}/hydra.c =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/8390}/lib8390.c =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/8390}/lne390.c =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/8390}/mac8390.c =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/8390}/ne-h8300.c =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/8390}/ne.c =A0 =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/8390}/ne2k-pci.c =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/8390}/ne3210.c =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/8390}/smc-mca.c =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/8390}/smc-ultra.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/8390}/smc-ultra32.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/8390}/stnic.c =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/8390}/wd.c =A0 =A0 =A0 =A0 =A0| =A0 =A0=
0
> =A0drivers/net/{ =3D> ethernet/8390}/zorro8390.c =A0 | =A0 =A00
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =
=A0 =A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A01 +
> =A032 files changed, 332 insertions(+), 309 deletions(-)
>
> commit 6b9ef2886e37d62018cd72dcdd2918e9fb982aed
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Wed Mar 30 07:46:36 2011 -0700
>
> =A0 =A0amd8111e/pcnet32/*lance/mvme147: Move AMD chipset drivers
>
> =A0 =A0Moves the drivers for the AMD chipsets into drivers/net/ethern=
et/amd/
> =A0 =A0and the necessary Kconfig and Makfile changes.
>
> =A0 =A0CC: Peter Maydell <pmaydell@chiark.greenend.org.uk>
> =A0 =A0CC: Roman Hodek <Roman.Hodek@informatik.uni-erlangen.de>
> =A0 =A0CC: "Maciej W. Rozycki" <macro@linux-mips.org>
> =A0 =A0CC: Donald Becker <becker@scyld.com>
> =A0 =A0CC: Sam Creasey <sammy@users.qual.net>
> =A0 =A0CC: Miguel de Icaza <miguel@nuclecu.unam.mx>
> =A0 =A0CC: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 | =A0 99 -----------------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
| =A0 =A09 --
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =
=A01 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
1 +
> =A0drivers/net/{ =3D> ethernet/amd}/7990.c =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/amd}/7990.h =A0 =A0 =A0 | =A0 =A00
> =A0drivers/net/ethernet/amd/Kconfig =A0 =A0 =A0 =A0 =A0 =A0| =A0115 +=
++++++++++++++++++++++++++
> =A0drivers/net/ethernet/amd/Makefile =A0 =A0 =A0 =A0 =A0 | =A0 13 +++
> =A0drivers/net/{ =3D> ethernet/amd}/amd8111e.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/amd}/amd8111e.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/amd}/atarilance.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/amd}/declance.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/amd}/hplance.c =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/amd}/hplance.h =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/amd}/lance.c =A0 =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/amd}/mvme147.c =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/amd}/pcnet32.c =A0 =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/amd}/sun3lance.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/amd}/sunlance.c =A0 | =A0 =A00
> =A019 files changed, 130 insertions(+), 108 deletions(-)
>
> commit b2ee2cf62d14c842272db622d6be6374bc6d622a
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Wed Mar 30 03:47:06 2011 -0700
>
> =A0 =A03c*/acenic/typhoon: Move 3Com Ethernet drivers
>
> =A0 =A0Moves the 3Com drivers into drivers/net/ethernet/3com/ and the=
 necessary
> =A0 =A0Kconfig and Makefile changes.
>
> =A0 =A0CC: Philip Blundell <philb@gnu.org>
> =A0 =A0CC: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
> =A0 =A0CC: David Dillow <dave@thedillows.org>
> =A0 =A0CC: Jes Sorensen <jes@trained-monkey.org>
> =A0 =A0CC: Alan Cox <alan@linux.intel.com>
> =A0 =A0CC: Donald Becker <becker@scyld.com>
> =A0 =A0CC: Craig Southeren <craigs@ineluki.apana.org.au>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 | =A0 =A08 +-
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =
=A0177 ----------------------------
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =
=A0 12 +--
> =A0drivers/net/{ =3D> ethernet/3com}/3c501.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/3com}/3c501.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/3com}/3c503.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/3com}/3c503.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/3com}/3c505.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/3com}/3c505.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/3com}/3c507.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/3com}/3c509.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/3com}/3c515.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/3com}/3c523.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/3com}/3c523.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/3com}/3c527.c =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/3com}/3c527.h =A0 | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/3com}/3c59x.c =A0 | =A0 =A00
> =A0drivers/net/ethernet/3com/Kconfig =A0 =A0 =A0 =A0 | =A0180 +++++++=
++++++++++++++++++++++
> =A0drivers/net/ethernet/3com/Makefile =A0 =A0 =A0 =A0| =A0 15 +++
> =A0drivers/net/{ =3D> ethernet/3com}/acenic.c =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/3com}/acenic.h =A0| =A0 =A00
> =A0drivers/net/{ =3D> ethernet/3com}/typhoon.c | =A0 =A00
> =A0drivers/net/{ =3D> ethernet/3com}/typhoon.h | =A0 =A00
> =A0drivers/net/ethernet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02=
 +
> =A0drivers/net/ethernet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A025 files changed, 203 insertions(+), 192 deletions(-)
>
> commit b918e3bb62b873c5436d413b99f593b3eed78901
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =A0 Tue Mar 29 18:25:21 2011 -0700
>
> =A0 =A0drivers/net/ethernet: Add ethernet dir and config option
>
> =A0 =A0This is the initial patch to organize the drivers/net director=
y
> =A0 =A0structure and networking device driver config options. =A0This=
 patch
> =A0 =A0does the following:
> =A0 =A0 =A0- add drivers/net/ethernet/Kconfig
> =A0 =A0 =A0- integrate the new files into the existing config
>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 | =A0 =A02 ++
> =A0drivers/net/Makefile =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
> =A0drivers/net/ethernet/Kconfig =A0| =A0 14 ++++++++++++++
> =A0drivers/net/ethernet/Makefile | =A0 =A04 ++++
> =A04 files changed, 21 insertions(+), 1 deletions(-)
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
