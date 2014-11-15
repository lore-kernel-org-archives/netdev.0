From: Johan Hovold <johan@kernel.org>
Subject: Re: phy/micrel: KSZ8031RNL RMII clock reconfiguration bug
Date: Sat, 15 Nov 2014 15:18:04 +0100
Message-ID: <20141115141804.GA24633@localhost>
References: <1412866094-4972-1-git-send-email-bth@kamstrup.dk>
 <20141111194101.GI29789@localhost>
 <915054555B5659448ACF8A70E114824D01704B9131@Exchange2010.kamstrup.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johan Hovold <johan@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"s.hauer@pengutronix.de" <s.hauer@pengutronix.de>,
	"bruno.thomsen@gmail.com" <bruno.thomsen@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Bruno Thomsen <bth@kamstrup.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <915054555B5659448ACF8A70E114824D01704B9131@Exchange2010.kamstrup.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 12, 2014 at 12:17:57PM +0000, Bruno Thomsen wrote:
> Hi Johan,
> 
> > As you may have seen by now, I've been working on refactoring the
> > micrel phy driver to be able to use common initialisation code.
> >
> > Specifically, I've added generic support for disabling the broadcast
> > address, which is what the MII_KSZPHY_OMSO write above does.
> >
> > Generally you want this to be the first thing you do in order to
> > avoid unnecessary reconfigurations. If we ever were to allow
> > concurrent probing this would also be a requirement.
> >
> > Could you provide some detail about the setup were you find that the
> > PHY becomes unresponsive without your patch? Do you have more than
> > one PHY on the bus? Using what addresses? And using what clock modes
> > (i.e. 25 MHz or 50 MHz)?
> > 
> > Also, what exactly do you mean by "unresponsive"? Are you still able
> > to read the PHY registers for example?
>  
> I think it sounds like a good idea to refactor the init code.
> 
> My setup:
> iMX28 processor with dual Ethernet MAC; FEC0 (enabled) and FEC1 (disabled).
> There is a single KSZ8031 PHY that receives 50MHz RMII clock from the MAC.
> I am unable to read PHY registers from both user-land tools and extra
> debug PHY reads in driver code.

Did you specify a led-mode as well, or was the Operation Mode Strap
Override (OMSO) write the first access after the soft reset?

Did you try any other workarounds besides setting the clock mode before
doing the OMSO write?

And REF_CLK (pin 16) is not connected? 

> Boot trace:
> [   22.277785] fec 800f0000.ethernet eth0: Freescale FEC PHY driver [Micrel KSZ8031] (mii_bus:phy_addr=800f0000.etherne:00, irq=-1)
> [   22.292527] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
> [   24.276217] libphy: 800f0000.etherne:00 - Link is Up - 100/Full
> [   24.285094] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

Ok, so you use a single PHY strapped to address 0. 

Would you able to test my series on your setup, and possibly a couple of
diagnostic patches on top?

Thanks,
Johan
