From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Microsemi VSC 8531/41 PHY Driver
Date: Fri, 29 Jul 2016 10:17:36 +0200
Message-ID: <20160729081736.GB13798@lunn.ch>
References: <646450A91FAED74E85C6E9C4D6E936A145329E4A@avsrvexchmbx1.microsemi.net>
 <20160726115556.GC11538@lunn.ch>
 <646450A91FAED74E85C6E9C4D6E936A145329E97@avsrvexchmbx1.microsemi.net>
 <20160726124347.GD11538@lunn.ch>
 <646450A91FAED74E85C6E9C4D6E936A14532A1E3@avsrvexchmbx1.microsemi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	Allan Nielsen <Allan.Nielsen@microsemi.com>
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53513 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750761AbcG2IRh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2016 04:17:37 -0400
Content-Disposition: inline
In-Reply-To: <646450A91FAED74E85C6E9C4D6E936A14532A1E3@avsrvexchmbx1.microsemi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +/* RGMII Rx Clock delay value change with board lay-out */ static u8 
> > +rgmii_rx_clk_delay = RGMII_RX_CLK_DELAY_1_1_NS;
> 
> Doesn't this stop you from having a board with two PHYs with different layouts? You should be getting this value from the device tree.
> 
> Raju: As of now, RGMII Rx clock delay value should be 1.1 nsec as optimized/recommended value. 
> We tested on Beaglebone Black with VSC 8531 PHY.
> We would like to provide new function to configure correct/require value based on PHY layouts 
> alone with other RGMII configuration parameters as part of our next implementation.

Please either do it properly now or hard code it as the default, and
then later replace it with device tree, etc. We don't like to see half
finished features.

> What are you locking against?
> 
> Raju: VSC 8531 has different PAGEs. Whenever MDC/MDIO access the PHY control registers, 
> first set the page number then read/write the register address. Default page should be Page 0.
> When I want to access not default page register, I have to lock phy device access and change 
> the page number and register access as atomic operation. 

I understand all that, which is why i asked, "what are you locking
against?", not "why are you locking?" What are the other call paths? I
don't see you taking this lock anywhere else? Should you be? I would
just like to see a comment which suggests you understand when this
lock is needed, and when not.

     Andrew
