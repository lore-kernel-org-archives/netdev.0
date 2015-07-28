From: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>
Subject: RE: [RFC PATCH 0/2] net: macb: Add mdio driver for accessing
 multiple phy devices
Date: Tue, 28 Jul 2015 03:34:51 +0000
Message-ID: <03CA77BA8AF6F1469AEDFBDA1322A7B749FC9CBA@XAP-PVEXMBX02.xlnx.xilinx.com>
References: <1436762920-32107-1-git-send-email-punnaia@xilinx.com>
 <55ACF7FC.4020408@xilinx.com> <55B5DFAF.4040909@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Harini Katakam <harinik@xilinx.com>,
	"kpc528@gmail.com" <kpc528@gmail.com>,
	"kalluripunnaiahchoudary@gmail.com"
	<kalluripunnaiahchoudary@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Michal Simek <michals@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0094.outbound.protection.outlook.com ([207.46.100.94]:46000
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755007AbbG1De4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 23:34:56 -0400
In-Reply-To: <55B5DFAF.4040909@atmel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nicolas,

> -----Original Message-----
> From: Nicolas Ferre [mailto:nicolas.ferre@atmel.com]
> Sent: Monday, July 27, 2015 1:07 PM
> To: Michal Simek; Punnaiah Choudary Kalluri; Anirudha Sarangi;
> davem@davemloft.net; Florian Fainelli; andrew@lunn.ch
> Cc: Harini Katakam; kpc528@gmail.com;
> kalluripunnaiahchoudary@gmail.com; netdev@vger.kernel.org; Punnaiah
> Choudary Kalluri
> Subject: Re: [RFC PATCH 0/2] net: macb: Add mdio driver for accessing
> multiple phy devices
>=20
> Le 20/07/2015 15:30, Michal Simek a =E9crit :
> > Hi Nicolas,
> >
> > have you had a time to look at this?
>=20
> Michal,
>=20
> Sorry for the delay.
>=20
> With the insight of Florian and Andrew, I do agree to move to your
> "Implementation 1" and a separate driver for mdio bus.
>=20
> The only thing that worries me it that the architecture AVR32 which w=
e
> are sharing this driver with doesn't have support for device tree (an=
d
> may never have). So, it would be good to make sure to keep compatibil=
ity
> with it.
>=20
> Another point to take into account is the transition period: we have
> several SoC .dtsi/dts that will need to be converted and we'll need t=
o
> add this mdio support before that it's integrated in netdev: we have =
to
> think about it in advance.

Ok. I will send you updated patch for mdio support soon and we will fin=
alize next
Course of actions if it doesn't break the existing flow.=20

Thanks,
Punnaiah
>=20
> Thanks, bye.
>=20
>=20
> > On 07/13/2015 06:48 AM, Punnaiah Choudary Kalluri wrote:
> >> This patch is to add support for the design that has multiple ethe=
rnet
> >> mac controllers and single mdio bus connected to multiple phy devi=
ces.
> >> i.e mdio lines are connected to any of the ethernet mac controller=
 and
> >> all the phy devices will be accessed using the phy maintenance int=
erface
> >> in that mac controller.
> >>
> >>  ______                   _____
> >> |      |                 |PHY0 |
> >> | MAC0 |-----------------|     |
> >> |______|       |         |_____|
> >>                |
> >>  ______        |          _____
> >> |      |       |         |     |
> >> | MAC1 |       |_________|PHY1 |
> >> |______|                 |____ |
> >>
> >> So, i come up with two implementations for addressing the above
> configuration.
> >>
> >> Implementation 1:
> >>  Have separate driver for mdio bus
> >>  Create a DT node for all the PHY devices connected to the mdio bu=
s
> >>  This driver will share the register space of the mac controller t=
hat has
> >>  mdio bus connected.
> >>
> >> Implementation 2:
> >>  Add new property "has-mdio" and it should be 1 for the mac that h=
as
> mdio bus
> >>  connected.
> >>  Create the mdio bus only when the has-mdio property is 1
> >>
> >> Please review the two implementations and suggest which one is bet=
ter
> to proceed
> >> further. In my opinion implementation 1 will be the ideal one.
> >>
> >> Currently i have tested the patches with single mac and single phy
> >> configuration. I need to take care of few more cases before releas=
ing the
> final patch
> >> but before that i would like to have your opinion on the above
> implementations
> >> and finalize one implementation. so that i can enhance it further.
> >>
> >> Punnaiah Choudary Kalluri (1):
> >>   net: macb: Add mdio driver for accessing multiple phy devices
> >>   net: macb: Add support for single mac managing more than one phy
> >>
> >>
> >>  drivers/net/ethernet/cadence/Makefile    |    2 +-
> >>  drivers/net/ethernet/cadence/macb.c      |   93 +-------------
> >>  drivers/net/ethernet/cadence/macb.h      |    3 +-
> >>  drivers/net/ethernet/cadence/macb_mdio.c |  204
> ++++++++++++++++++++++++++++++
> >>  4 files changed, 211 insertions(+), 91 deletions(-)
> >>  create mode 100644 drivers/net/ethernet/cadence/macb_mdio.c
> >>
> >
> >
> >
>=20
>=20
> --
> Nicolas Ferre
