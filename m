From: punnaiah choudary kalluri <punnaia@xilinx.com>
Subject: Re: [RFC PATCH 0/2] net: macb: Add mdio driver for accessing multiple
 phy devices
Date: Tue, 14 Jul 2015 08:32:08 +0530
Message-ID: <CAGnW=Bb4sLvdiDC7AU24jMH84bW8t6CNwrhUpfrSxGYVzMqJ_w@mail.gmail.com>
References: <1436762920-32107-1-git-send-email-punnaia@xilinx.com>
	<55A406BE.5090300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>,
	nicolas.ferre@atmel.com, "michals@xilinx.com" <michals@xilinx.com>,
	anirudh@xilinx.com, davem@davemloft.net, harinik@xilinx.com,
	Punnaiah Choudary <kpc528@gmail.com>, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:36414 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931AbbGNDCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 23:02:09 -0400
Received: by obnw1 with SMTP id w1so15899111obn.3
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 20:02:08 -0700 (PDT)
In-Reply-To: <55A406BE.5090300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 14, 2015 at 12:13 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 12/07/15 21:48, Punnaiah Choudary Kalluri wrote:
>> This patch is to add support for the design that has multiple ethernet
>> mac controllers and single mdio bus connected to multiple phy devices.
>> i.e mdio lines are connected to any of the ethernet mac controller and
>> all the phy devices will be accessed using the phy maintenance interface
>> in that mac controller.
>>
>>  ______                   _____
>> |      |                 |PHY0 |
>> | MAC0 |-----------------|     |
>> |______|       |         |_____|
>>                |
>>  ______        |          _____
>> |      |       |         |     |
>> | MAC1 |       |_________|PHY1 |
>> |______|                 |____ |
>>
>> So, i come up with two implementations for addressing the above configuration.
>>
>> Implementation 1:
>>  Have separate driver for mdio bus
>>  Create a DT node for all the PHY devices connected to the mdio bus
>>  This driver will share the register space of the mac controller that has
>>  mdio bus connected.
>
> That is the best design implementation, MDIO in itself is a sub-piece of
> your Ethernet MAC controller the fact that it is within the Ethernet MAC
> core is just coincidental, but there is no reason why it could not be
> taken apart and made a separate block in itself.

Thanks Florian for suggesting this.
No idea on why the mdio block was not made a separate block.

regards,
Punnaiah

>
>>
>> Implementation 2:
>>  Add new property "has-mdio" and it should be 1 for the mac that has mdio bus
>>  connected.
>>  Create the mdio bus only when the has-mdio property is 1
>>
>> Please review the two implementations and suggest which one is better to proceed
>> further. In my opinion implementation 1 will be the ideal one.
>
> Agreed.
>
>>
>> Currently i have tested the patches with single mac and single phy
>> configuration. I need to take care of few more cases before releasing the final patch
>> but before that i would like to have your opinion on the above implementations
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
>>  drivers/net/ethernet/cadence/macb_mdio.c |  204 ++++++++++++++++++++++++++++++
>>  4 files changed, 211 insertions(+), 91 deletions(-)
>>  create mode 100644 drivers/net/ethernet/cadence/macb_mdio.c
>>
>
>
> --
> Florian
