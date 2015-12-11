From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH RFC 10/26] phy: add I2C mdio bus
Date: Fri, 11 Dec 2015 10:25:24 +0000
Message-ID: <20151211102524.GQ8644@n2100.arm.linux.org.uk>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk>
 <E1a5zje-00075T-LA@rmk-PC.arm.linux.org.uk>
 <56671E2C.4000508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:42277 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbbLKKZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 05:25:36 -0500
Content-Disposition: inline
In-Reply-To: <56671E2C.4000508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 08, 2015 at 10:15:08AM -0800, Florian Fainelli wrote:
> On 07/12/15 09:38, Russell King wrote:
> > Add an I2C MDIO bus bridge library, to allow phylib to access PHYs which
> > are connected to an I2C bus instead of the more conventional MDIO bus.
> > Such PHYs can be found in SFP adapters and SFF modules.
> > 
> > Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> > ---
> [snip]
> > +static int i2c_mii_read(struct mii_bus *bus, int phy_id, int reg)
> > +{
> > +	struct i2c_adapter *i2c = bus->priv;
> > +	struct i2c_msg msgs[2];
> > +	u8 data[2], dev_addr = reg;
> > +	int bus_addr, ret;
> > +
> > +	bus_addr = 0x40 + phy_id;
> > +	if (bus_addr == 0x50 || bus_addr == 0x51)
> > +		return 0xffff;
> 
> These could deserve a local definition for these specific addresses so
> we know why there is such logic here.

This is the only comment I've received on this series so far; I'm
waiting for further comments before addressing it.

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
