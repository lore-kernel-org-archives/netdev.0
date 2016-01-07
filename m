From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCHv2 net-next 00/22] Support MDIO devices
Date: Thu, 07 Jan 2016 14:53:22 -0800
Message-ID: <568EEC62.1080304@gmail.com>
References: <1452107487-475-1-git-send-email-andrew@lunn.ch> <20160107.143357.139530014387548318.davem@davemloft.net> <20160107201434.GD1356@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34372 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752817AbcAGWx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 17:53:56 -0500
Received: by mail-pf0-f182.google.com with SMTP id q63so154825pfb.1
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 14:53:56 -0800 (PST)
In-Reply-To: <20160107201434.GD1356@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01/16 12:14, Andrew Lunn wrote:
> On Thu, Jan 07, 2016 at 02:33:57PM -0500, David Miller wrote:
>> From: Andrew Lunn <andrew@lunn.ch>
>> Date: Wed,  6 Jan 2016 20:11:05 +0100
>>
>>> The discussions about changing the way DSA probes switches resulted in
>>> the wish to have switches attached to an MDIO bus to be represented as
>>> an MDIO device. However the current code only supports PHYs on MDIO
>>> busses. This patchset remedies this problem. It consists of a number
>>> of cleanups, abstraction for accessing structure members, and
>>> refactoring, as well as adding the concept of a generic MDIO device
>>> and MDIO driver.
>>>
>>> v2:
>>> Added Reviewed-by from Florian
>>> Made phydev_name() an inline function
>>> Added phy_attached_info/phy_attached_print() for information about
>>> the attached phy.
>>> Removed now redundant irq setup from of_mdio.c
>>> Dropped hunks from PHYMII ioctl which prevented access to any address
>>> DSA carrier off before phy setup
>>
>> Series applied, thanks Andrew.
> 
> Hi Dave
> 
> You might get some build failures from less well used
> architectures/drivers.  I've got a couple of 0-day emails i need to
> send fixups for.

Just for completeness, I boot tested this on a BCM7445 (bcm_sf2 +
bcm7xxx PHY driver + mdio-bcm-unimac) and this worked like a charm, thanks!

[    1.218140] Distributed Switch Architecture driver version 0.1
[    1.224051] brcm-systemport f04a0000.ethernet eth0: [0]: detected a
Broadcom Starfighter 2 switch
[    1.233159] Starfighter 2 top: 4.00, core: 2.00 base: 0xf0c00000,
IRQs: 65, 66
[    1.240874] libphy: dsa slave smi: probed
[    1.302102] f0b403c0.mdio:05: Broadcom BCM7445 PHY revision: 0xd0,
patch: 3
[    1.616888] Broadcom BCM7445 f0b403c0.mdio:05: attached PHY driver
[Broadcom BCM7445] (mii_bus:phy_addr=f0b403c0.mdio:05, irq=-1)
[    1.681215] Generic PHY dsa-0:00:00: attached PHY driver [Generic
PHY] (mii_bus:phy_addr=dsa-0:00:00, irq=-1)
[    1.744103] Generic PHY fixed-0:01: attached PHY driver [Generic PHY]
(mii_bus:phy_addr=fixed-0:01, irq=-1)
[    1.807103] Generic PHY fixed-0:02: attached PHY driver [Generic PHY]
(mii_bus:phy_addr=fixed-0:02, irq=-1)

-- 
Florian
