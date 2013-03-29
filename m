From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 2/4] ARM: kirkwood: add device node entries for the gigabit
 interfaces
Date: Fri, 29 Mar 2013 19:51:53 +0100
Message-ID: <5155E2C9.9050201@openwrt.org>
References: <1364580879-4297-1-git-send-email-florian@openwrt.org> <1364580879-4297-3-git-send-email-florian@openwrt.org> <20130329184852.GM13280@titan.lakedaemon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	devicetree-discuss@lists.ozlabs.org,
	thomas.petazzoni@free-electrons.com, jm@lentin.co.uk,
	moinejf@free.fr, sebastian.hesselbarth@gmail.com,
	buytenh@wantstofly.org, andrew@lunn.ch, grant.likely@secretlab.ca,
	rob.herring@calxeda.com
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:61658 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756641Ab3C2SwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 14:52:09 -0400
Received: by mail-wg0-f45.google.com with SMTP id x12so660227wgg.12
        for <netdev@vger.kernel.org>; Fri, 29 Mar 2013 11:52:08 -0700 (PDT)
In-Reply-To: <20130329184852.GM13280@titan.lakedaemon.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/29/13 19:48, Jason Cooper a =C3=A9crit :
> On Fri, Mar 29, 2013 at 07:14:37PM +0100, Florian Fainelli wrote:
>> This patch modifies kirkwood.dtsi to specify the various gigabit
>> interfaces nodes available on kirkwood devices. They are disabled by
>> default and should be enabled on a per-board basis. egiga0 and egiga=
1
>> aliases are defined for convenience. The mdio node is also present a=
nd
>> should be enabled on a per-board basis as well.
>>
>> Signed-off-by: Florian Fainelli <florian@openwrt.org>
>> ---
>>   arch/arm/boot/dts/kirkwood.dtsi |   46 +++++++++++++++++++++++++++=
++++++++++++
>>   arch/arm/mach-kirkwood/common.c |    4 ++--
>>   2 files changed, 48 insertions(+), 2 deletions(-)
>>
> ...
>> diff --git a/arch/arm/mach-kirkwood/common.c b/arch/arm/mach-kirkwoo=
d/common.c
>> index 49792a0..a606f9f 100644
>> --- a/arch/arm/mach-kirkwood/common.c
>> +++ b/arch/arm/mach-kirkwood/common.c
>> @@ -251,8 +251,8 @@ void __init kirkwood_clk_init(void)
>>   	/* clkdev entries, mapping clks to devices */
>>   	orion_clkdev_add(NULL, "orion_spi.0", runit);
>>   	orion_clkdev_add(NULL, "orion_spi.1", runit);
>> -	orion_clkdev_add(NULL, MV643XX_ETH_NAME ".0", ge0);
>> -	orion_clkdev_add(NULL, MV643XX_ETH_NAME ".1", ge1);
>> +	orion_clkdev_add("0", MV643XX_ETH_NAME ".0", ge0);
>> +	orion_clkdev_add("1", MV643XX_ETH_NAME ".1", ge1);
>
> Your first patch is going to go through David's tree, and I'd like to
> prevent any hard dependency between his tree and arm-soc.  Can this
> change be pulled out and applied separately?  At first glance, it loo=
ks
> like a fix to match sata and pcie.

I just actually did the same thing as what SATA has (two clocks with=20
names), define a clock name "0" and "1" (is not that too generic BTW?)=20
for ge0 and ge1. But I don't think this change is required.
--
=46lorian
