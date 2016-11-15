From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [net-next 1/2] net: ethernet: slicoss: add slicoss gigabit
 ethernet driver
Date: Tue, 15 Nov 2016 23:34:38 +0100
Message-ID: <86165d2b-f9d5-a380-9bb0-f77c12691eb6@gmx.de>
References: <1479012453-19410-1-git-send-email-LinoSanfilippo@gmx.de>
 <1479012453-19410-2-git-send-email-LinoSanfilippo@gmx.de>
 <20161113195544.GA18258@lunn.ch>
 <69558f55-824a-7063-d9b3-ccc0a6113b87@gmx.de>
 <4450caf4-e1cf-5187-1337-c46b81b08708@gmail.com>
 <0d1b4dee-11bb-3605-699c-ea417484cb68@gmx.de>
 <20161115215907.GF23231@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
        charrer@alacritech.com, liodot@gmail.com,
        gregkh@linuxfoundation.org, devel@driverdev.osuosl.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:61461 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752194AbcKOWfI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 17:35:08 -0500
In-Reply-To: <20161115215907.GF23231@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.11.2016 22:59, Andrew Lunn wrote:
>> The link state is retrieved by a command to the application processor that is running 
>> on the network card. Also the register to set the phy configuration is write-only, so
>> it is not even possible to do the usual mdio bit-banging in the Phy read() and write()
>> functions (however there seems to be another application processor command reserved 
>> for retrieving the PHY settings, but I have not tried it yet). 
> 
>>> +  			val = MII_BMCR << 16 | SLIC_PCR_AUTONEG |
>>> +		     	         SLIC_PCR_AUTONEG_RST;
>>> +			slic_write(sdev, SLIC_REG_WPHY, val);
> 
> This actually looks a lot like an MDIO write operation. The upper 16
> bits are the register, and the lower 16 bits are the data. What you
> don't have is the address. But maybe it is limited to one address.
> 
> If the processor command reserved for read works in a similar way, you
> have enough to do an MDIO bus.
> 

Ok, I will give it a try. Reading values via the application processor
is a bit awkward though, since it requires an address to a dma area as part of
the command and then the AP informs the driver via irq that the dma memory has 
been written. So probably the irq handler will have to set some flag and
the mdio_read() function will have to poll for that flag in place of doing 
bit-banging a register. 

> If you can get the read working look at registers 2 and 3. Compare
> what you get with the values at the end of marvell.c.
> 

Will do, thank you!

Lino
