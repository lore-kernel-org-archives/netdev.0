From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [RFC] Moving files around in drivers/net
Date: Thu, 16 Jun 2011 11:34:02 +0800
Message-ID: <BANLkTinb0U+=rbK65Xs+E+GBwqvVSV_a9A@mail.gmail.com>
References: <1306956602.32125.28.camel@Joe-Laptop> <1306957998.3076.18.camel@jtkirshe-MOBL1>
 <1306958478.32125.32.camel@Joe-Laptop> <BANLkTi=BAqKzZeLF2_uCYnr7PD3StGFgAg@mail.gmail.com>
 <1308186619.12377.23.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Jan Engelhardt <jengelh@medozas.de>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60673 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751921Ab1FPDeX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2011 23:34:23 -0400
Received: by fxm17 with SMTP id 17so828642fxm.19
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2011 20:34:22 -0700 (PDT)
In-Reply-To: <1308186619.12377.23.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Joe,

On Thu, Jun 16, 2011 at 9:10 AM, Joe Perches <joe@perches.com> wrote:
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
>> weekend, but I keep getting interrupted. =C2=A0(Blame it on the NHL =
stanley
>> cup playoffs) :)
>> I have created a git tree on kernel.org with all the work that I hav=
e
>> completed so far (see below). =C2=A0This first stage of the move is =
only
>> taking care of the drivers. =C2=A0The next stage will move the netwo=
rking
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
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pkteng should be packetengines
> And things maybe not spelled out
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ixp2000 might just be ixp (what not intel?=
:)
>
> And maybe drivers/net/ethernet/ should be as
> unpopulated as possible. =C2=A0Maybe create a misc
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
> stmmac may not be a good name. =C2=A0Maybe stmicro.
>
> enic may not be a good name. =C2=A0Maybe cisco.
>
> mlx4 may be mellanox
>
> sfc may be solarflare
>
> bna may be brocade
>
> cheers, Joe
>

[snip...]

> commit 5fe875b9e93af6b5a099b37471bebb541f1ba0c6
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: =C2=A0 Thu May 19 22:06:03 2011 -0700
>
> =C2=A0 =C2=A0arm: Move the ARM/ACORN drivers
>
> =C2=A0 =C2=A0Move the ARM/ACORN drivers into drivers/net/ethernet/arm=
/ and make the
> =C2=A0 =C2=A0necessary Kconfig and Makefile changes.
> =C2=A0 =C2=A0There were 4 drivers (TI Davinci & ftmac100) not in the
> =C2=A0 =C2=A0drivers/net/arm/ which should have been since they are o=
nly supported
> =C2=A0 =C2=A0under ARM, so they were added to the new directory struc=
ture.
>
> =C2=A0 =C2=A0NOTE: There are no "maintainers" for the TI Davinci driv=
ers, so I am
> =C2=A0 =C2=A0CC'ing the last 3 major contributors from TI.
>
> =C2=A0 =C2=A0CC: Sriram <srk@ti.com>
> =C2=A0 =C2=A0CC: Vinay Hegde <vinay.hegde@ti.com>
> =C2=A0 =C2=A0CC: Cyril Chemparathy <cyril@ti.com>
> =C2=A0 =C2=A0CC: Russell King <linux@arm.linux.org.uk>
> =C2=A0 =C2=A0CC: Wan ZongShun <mcuos.com@gmail.com>
> =C2=A0 =C2=A0CC: Lennert Buytenhek <kernel@wantstofly.org>
> =C2=A0 =C2=A0CC: Krzysztof Halasa <khc@pm.waw.pl>
> =C2=A0 =C2=A0CC: Po-Yu Chuang <ratbert@faraday-tech.com>
> =C2=A0 =C2=A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com=
>
>
> =C2=A0MAINTAINERS =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
| =C2=A0 10 +-
> =C2=A0drivers/net/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 51 -------=
--
> =C2=A0drivers/net/Makefile =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A07 --
> =C2=A0drivers/net/arm/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 74 -------------
> =C2=A0drivers/net/ethernet/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A01 +
> =C2=A0drivers/net/ethernet/Makefile =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A01 +
> =C2=A0drivers/net/ethernet/arm/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 | =C2=A0138 ++++++++++++++++++++++++
> =C2=A0drivers/net/{ =3D> ethernet}/arm/Makefile =C2=A0 =C2=A0 =C2=A0 =
=C2=A0| =C2=A0 =C2=A06 +-
> =C2=A0drivers/net/{ =3D> ethernet}/arm/am79c961a.c =C2=A0 =C2=A0 | =C2=
=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet}/arm/am79c961a.h =C2=A0 =C2=A0 | =C2=
=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet}/arm/at91_ether.c =C2=A0 =C2=A0| =C2=
=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet}/arm/at91_ether.h =C2=A0 =C2=A0| =C2=
=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet/arm}/davinci_cpdma.c | =C2=A0 =C2=A0=
0
> =C2=A0drivers/net/{ =3D> ethernet/arm}/davinci_cpdma.h | =C2=A0 =C2=A0=
0
> =C2=A0drivers/net/{ =3D> ethernet/arm}/davinci_emac.c =C2=A0| =C2=A0 =
=C2=A00
> =C2=A0drivers/net/{ =3D> ethernet/arm}/davinci_mdio.c =C2=A0| =C2=A0 =
=C2=A00
> =C2=A0drivers/net/{ =3D> ethernet}/arm/ep93xx_eth.c =C2=A0 =C2=A0| =C2=
=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet}/arm/ether1.c =C2=A0 =C2=A0 =C2=A0 =
=C2=A0| =C2=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet}/arm/ether1.h =C2=A0 =C2=A0 =C2=A0 =
=C2=A0| =C2=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet}/arm/ether3.c =C2=A0 =C2=A0 =C2=A0 =
=C2=A0| =C2=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet}/arm/ether3.h =C2=A0 =C2=A0 =C2=A0 =
=C2=A0| =C2=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet}/arm/etherh.c =C2=A0 =C2=A0 =C2=A0 =
=C2=A0| =C2=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet/arm}/ftgmac100.c =C2=A0 =C2=A0 | =C2=
=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet/arm}/ftgmac100.h =C2=A0 =C2=A0 | =C2=
=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet/arm}/ftmac100.c =C2=A0 =C2=A0 =C2=A0=
| =C2=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet/arm}/ftmac100.h =C2=A0 =C2=A0 =C2=A0=
| =C2=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet}/arm/ixp4xx_eth.c =C2=A0 =C2=A0| =C2=
=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet}/arm/ks8695net.c =C2=A0 =C2=A0 | =C2=
=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet}/arm/ks8695net.h =C2=A0 =C2=A0 | =C2=
=A0 =C2=A00
> =C2=A0drivers/net/{ =3D> ethernet}/arm/w90p910_ether.c | =C2=A0 =C2=A0=
0
> =C2=A030 files changed, 150 insertions(+), 138 deletions(-)
>

[snip...]

=46araday ftmac100 and ftgmac100 are used by not only ARM SoCs.
There are SoCs of NDS32 architecture use these controllers, but
NDS32 architecture is not in Linux mainline (yet).
If these drivers were moved to arm directory, they maybe need to be
moved out of it someday.

So, how about:
driver/net{ =3D> ethernet/faraday}/ftmac100.c
driver/net{ =3D> ethernet/faraday}/ftgmac100.c

Best regards,
Po-Yu Chuang
