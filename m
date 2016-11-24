From: "Lino Sanfilippo" <LinoSanfilippo@gmx.de>
Subject: Aw: Re: [net-next 1/2] net: ethernet: slicoss: add slicoss gigabit
 ethernet driver
Date: Thu, 24 Nov 2016 13:30:13 +0100
Message-ID: <trinity-689864d1-7519-49c5-9c6d-8366a1841360-1479990613647@3capp-gmx-bs64>
References: <1479012453-19410-1-git-send-email-LinoSanfilippo@gmx.de>
 <1479012453-19410-2-git-send-email-LinoSanfilippo@gmx.de>
 <20161113195544.GA18258@lunn.ch>
 <69558f55-824a-7063-d9b3-ccc0a6113b87@gmx.de>
 <4450caf4-e1cf-5187-1337-c46b81b08708@gmail.com>
 <0d1b4dee-11bb-3605-699c-ea417484cb68@gmx.de>
 <20161115215907.GF23231@lunn.ch>,
 <86165d2b-f9d5-a380-9bb0-f77c12691eb6@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, charrer@alacritech.com, liodot@gmail.com,
        gregkh@linuxfoundation.org, devel@driverdev.osuosl.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        LinoSanfilippo@gmx.de
To: f.fainelli@gmail.com, andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <86165d2b-f9d5-a380-9bb0-f77c12691eb6@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew, Hi Florian

> Gesendet: Dienstag, 15. November 2016 um 23:34 Uhr
> Von: "Lino Sanfilippo" <LinoSanfilippo@gmx.de>
> An: "Andrew Lunn" <andrew@lunn.ch>
> Cc: "Florian Fainelli" <f.fainelli@gmail.com>, davem@davemloft.net, charrer@alacritech.com, liodot@gmail.com, gregkh@linuxfoundation.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
> Betreff: Re: [net-next 1/2] net: ethernet: slicoss: add slicoss gigabit ethernet driver
>
> On 15.11.2016 22:59, Andrew Lunn wrote:
> >> The link state is retrieved by a command to the application processor that is running 
> >> on the network card. Also the register to set the phy configuration is write-only, so
> >> it is not even possible to do the usual mdio bit-banging in the Phy read() and write()
> >> functions (however there seems to be another application processor command reserved 
> >> for retrieving the PHY settings, but I have not tried it yet). 
> > 
> >>> +  			val = MII_BMCR << 16 | SLIC_PCR_AUTONEG |
> >>> +		     	         SLIC_PCR_AUTONEG_RST;
> >>> +			slic_write(sdev, SLIC_REG_WPHY, val);
> > 
> > This actually looks a lot like an MDIO write operation. The upper 16
> > bits are the register, and the lower 16 bits are the data. What you
> > don't have is the address. But maybe it is limited to one address.
> > 
> > If the processor command reserved for read works in a similar way, you
> > have enough to do an MDIO bus.
> > 
> 
> Ok, I will give it a try. Reading values via the application processor
> is a bit awkward though, since it requires an address to a dma area as part of
> the command and then the AP informs the driver via irq that the dma memory has 
> been written. So probably the irq handler will have to set some flag and
> the mdio_read() function will have to poll for that flag in place of doing 
> bit-banging a register. 
> 
> > If you can get the read working look at registers 2 and 3. Compare
> > what you get with the values at the end of marvell.c.
> > 
> 
> Will do, thank you!
> 

unfortunately I was not able to figure out how to read the phy. My hope was to find
a hidden register that I can use to request the phy status from the cards utility processor.
I actually found two more registers that seem to be reserved for the communication
with the UP. At least they cause the UPR irq to be fired but there is no data written to
the provided dma address. I assume that they are not meant to be used for the this purpose.
So I am afraid I am not able to use the phy API in this driver for now. 
However I will send a v2 of the driver shortly that will include the other
changes suggested by Andrew along with some further small improvements.
Thanks for your help so far!

Regards,
Lino
