From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [RFC PATCH 0/2] net: macb: Add mdio driver for accessing multiple
 phy devices
Date: Mon, 27 Jul 2015 09:37:19 +0200
Message-ID: <55B5DFAF.4040909@atmel.com>
References: <1436762920-32107-1-git-send-email-punnaia@xilinx.com> <55ACF7FC.4020408@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <harinik@xilinx.com>, <kpc528@gmail.com>,
	<kalluripunnaiahchoudary@gmail.com>, <netdev@vger.kernel.org>,
	"Punnaiah Choudary Kalluri" <punnaia@xilinx.com>
To: Michal Simek <michal.simek@xilinx.com>,
	Punnaiah Choudary Kalluri
	<punnaiah.choudary.kalluri@xilinx.com>, <anirudh@xilinx.com>,
	<davem@davemloft.net>, Florian Fainelli <f.fainelli@gmail.com>,
	<andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.242]:29151 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164AbbG0Hi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 03:38:28 -0400
In-Reply-To: <55ACF7FC.4020408@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 20/07/2015 15:30, Michal Simek a =E9crit :
> Hi Nicolas,
>=20
> have you had a time to look at this?

Michal,

Sorry for the delay.

With the insight of Florian and Andrew, I do agree to move to your
"Implementation 1" and a separate driver for mdio bus.

The only thing that worries me it that the architecture AVR32 which we
are sharing this driver with doesn't have support for device tree (and
may never have). So, it would be good to make sure to keep compatibilit=
y
with it.

Another point to take into account is the transition period: we have
several SoC .dtsi/dts that will need to be converted and we'll need to
add this mdio support before that it's integrated in netdev: we have to
think about it in advance.

Thanks, bye.


> On 07/13/2015 06:48 AM, Punnaiah Choudary Kalluri wrote:
>> This patch is to add support for the design that has multiple ethern=
et
>> mac controllers and single mdio bus connected to multiple phy device=
s.
>> i.e mdio lines are connected to any of the ethernet mac controller a=
nd
>> all the phy devices will be accessed using the phy maintenance inter=
face
>> in that mac controller.
>>
>>  ______                   _____
>> |      |                 |PHY0 |
>> | MAC0 |-----------------|     |
>> |______|       |         |_____|
>>                |          =20
>>  ______        |          _____
>> |      |       |         |     |
>> | MAC1 |       |_________|PHY1 |=20
>> |______|                 |____ |
>>
>> So, i come up with two implementations for addressing the above conf=
iguration.
>>
>> Implementation 1:
>>  Have separate driver for mdio bus
>>  Create a DT node for all the PHY devices connected to the mdio bus
>>  This driver will share the register space of the mac controller tha=
t has
>>  mdio bus connected. =20
>>
>> Implementation 2:
>>  Add new property "has-mdio" and it should be 1 for the mac that has=
 mdio bus
>>  connected.
>>  Create the mdio bus only when the has-mdio property is 1
>>
>> Please review the two implementations and suggest which one is bette=
r to proceed
>> further. In my opinion implementation 1 will be the ideal one.
>>
>> Currently i have tested the patches with single mac and single phy
>> configuration. I need to take care of few more cases before releasin=
g the final patch
>> but before that i would like to have your opinion on the above imple=
mentations
>> and finalize one implementation. so that i can enhance it further.
>>
>> Punnaiah Choudary Kalluri (1):
>>   net: macb: Add mdio driver for accessing multiple phy devices
>>   net: macb: Add support for single mac managing more than one phy
>>
>>
>>  drivers/net/ethernet/cadence/Makefile    |    2 +-
>>  drivers/net/ethernet/cadence/macb.c      |   93 +-------------
>>  drivers/net/ethernet/cadence/macb.h      |    3 +-
>>  drivers/net/ethernet/cadence/macb_mdio.c |  204 +++++++++++++++++++=
+++++++++++
>>  4 files changed, 211 insertions(+), 91 deletions(-)
>>  create mode 100644 drivers/net/ethernet/cadence/macb_mdio.c
>>
>=20
>=20
>=20


--=20
Nicolas Ferre
