From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: davinci-mdio: failing to connect to PHY
Date: Mon, 4 Apr 2016 14:31:45 +0200
Message-ID: <20160404123145.GE21828@lunn.ch>
References: <57022356.6010309@barix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Petr Kulhavy <petr@barix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45768 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751968AbcDDMbq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2016 08:31:46 -0400
Content-Disposition: inline
In-Reply-To: <57022356.6010309@barix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 04, 2016 at 10:18:30AM +0200, Petr Kulhavy wrote:
> Hi,
> 
> I'm experiencing a peculiar problem with PHY communication in the
> current davinci-mdio.c driver.
> After upgrading from kernel 3.17 to 4.5 my DT based AM1808 board
> started having issues with the PHY communication.
> The MAC is detected, the MDIO is detected, the PHY is detected
> (twice?!?!), however there is no data being sent/received and the
> after issuing "ifdown -a" the MDIO starts spitting out messages that
> it cannot connect to the PHY:
> 
> net eth0: could not connect to phy davinci_mdio.0:00
> davinci_mdio davinci_mdio.0: resetting idled controller
> 
> 
> I'm using a single Micrel KSZ8081 PHY connected via RMII using the
> default PHY address 0x01.
> Here is the dmesg excerpt related to mdio:
> 
> davinci_mdio davinci_mdio.0: Runtime PM disabled, clock forced on.
> davinci_mdio davinci_mdio.0: davinci mdio revision 1.5
> davinci_mdio davinci_mdio.0: detected phy mask fffffffc
> libphy: davinci_mdio.0: probed
> davinci_mdio davinci_mdio.0: phy[0]: device davinci_mdio.0:00,
> driver Micrel KSZ8081 or KSZ8091
> davinci_mdio davinci_mdio.0: phy[1]: device davinci_mdio.0:01,
> driver Micrel KSZ8081 or KSZ8091
> davinci_mdio davinci_mdio.0: resetting idled controller
> Micrel KSZ8081 or KSZ8091 davinci_mdio.0:00: failed to disable NAND
> tree mode
> Micrel KSZ8081 or KSZ8091 davinci_mdio.0:00: attached PHY driver
> [Micrel KSZ8081 or KSZ8091] (mii_bus:phy_addr=davinci_mdio.0:00,
> irq=-1)
> 
> 
> After a soft-reboot the MDIO uses a different PHY mask fffffffd,
> detects correctly only one PHY at address 1 (this is the default
> address) and the networking works:
 
Hi Petr

You might want to take a look at:

http://lxr.free-electrons.com/source/drivers/net/ethernet/ti/davinci_mdio.c#L137

It seems to be asking the hardware about the phy mask.

   Andrew
