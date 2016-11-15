From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [net-next 1/2] net: ethernet: slicoss: add slicoss gigabit
 ethernet driver
Date: Tue, 15 Nov 2016 22:59:07 +0100
Message-ID: <20161115215907.GF23231@lunn.ch>
References: <1479012453-19410-1-git-send-email-LinoSanfilippo@gmx.de>
 <1479012453-19410-2-git-send-email-LinoSanfilippo@gmx.de>
 <20161113195544.GA18258@lunn.ch>
 <69558f55-824a-7063-d9b3-ccc0a6113b87@gmx.de>
 <4450caf4-e1cf-5187-1337-c46b81b08708@gmail.com>
 <0d1b4dee-11bb-3605-699c-ea417484cb68@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
        charrer@alacritech.com, liodot@gmail.com,
        gregkh@linuxfoundation.org, devel@driverdev.osuosl.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41098 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933957AbcKOV7S (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 16:59:18 -0500
Content-Disposition: inline
In-Reply-To: <0d1b4dee-11bb-3605-699c-ea417484cb68@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The link state is retrieved by a command to the application processor that is running 
> on the network card. Also the register to set the phy configuration is write-only, so
> it is not even possible to do the usual mdio bit-banging in the Phy read() and write()
> functions (however there seems to be another application processor command reserved 
> for retrieving the PHY settings, but I have not tried it yet). 

>> +  			val = MII_BMCR << 16 | SLIC_PCR_AUTONEG |
>> +		     	         SLIC_PCR_AUTONEG_RST;
>> +			slic_write(sdev, SLIC_REG_WPHY, val);

This actually looks a lot like an MDIO write operation. The upper 16
bits are the register, and the lower 16 bits are the data. What you
don't have is the address. But maybe it is limited to one address.

If the processor command reserved for read works in a similar way, you
have enough to do an MDIO bus.

> Please also note that I do not have any datasheets or other documentation for the hardware, 
> all I have as a reference is the driver code in staging. So I do not know which 
> PHYs are actually used (the comments in the code mention Marvell and Cicada but this is
> not very specific).

If you can get the read working look at registers 2 and 3. Compare
what you get with the values at the end of marvell.c.

     Andrew
