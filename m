From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: ethernet: mvneta: add support for 2.5G DRSGMII mode
Date: Tue, 24 Jan 2017 14:19:55 +0100
Message-ID: <20170124131955.GA27016@lunn.ch>
References: <20170123142206.5390-1-jlu@pengutronix.de>
 <20170123181836.GO10895@lunn.ch>
 <1485246858.5508.47.camel@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        davem@davemloft.net, Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Jan =?iso-8859-1?Q?L=FCbbe?= <jlu@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43630 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750739AbdAXNUB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 08:20:01 -0500
Content-Disposition: inline
In-Reply-To: <1485246858.5508.47.camel@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> It works without any other changes. ;)
> 
> Initially I looked at adding a SPEED_2500, but I wasn't sure which code
> would need to handle the new value. Would the path from the ethtool
> ioctl to the driver be enough (mvneta_ethtool_set_link_ksettings() as
> you said)?

You have this connected to an FPGA? Do you have a traditional PHY in
the FPGA? Or are you implementing something more like an Ethernet
switch?

I don't know this driver too well, but what often happens is the PHY
performs autoneg and the phylib then calls the adjust_link function to
set the MAC to what has been negotiated. So if you have a PHY attached
which can do 2.5Ghz, you might be seeing calls to adjust_link with
SPEED_2500.

What does ethtool <devname> show?

Thanks
     Andrew
