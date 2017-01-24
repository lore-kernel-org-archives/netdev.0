From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 5/5] net: dsa: mv88e6xxx: Implement the 6390
 external MDIO bus
Date: Tue, 24 Jan 2017 20:54:05 +0100
Message-ID: <20170124195405.GR10895@lunn.ch>
References: <1485266031-4980-1-git-send-email-andrew@lunn.ch>
 <1485266031-4980-6-git-send-email-andrew@lunn.ch>
 <871svscpt9.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44023 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751026AbdAXTyQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 14:54:16 -0500
Content-Disposition: inline
In-Reply-To: <871svscpt9.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2017 at 12:48:02PM -0500, Vivien Didelot wrote:
> Hi Andrew,
> 
> Sorry but the previous patches with a list of MDIO busses and refactored
> PHY ops still seems too much complex to just toggle a bit.
> 
> We know which switch port has an external PHY attached to it, right?

No, not really. We have the full flexibility of phandles in the device
tree. The PHYs on the external bus might not even be connected to the
switch, they could be for the host interfaces, for example. And you
don't even need to use the internal PHYs. If you are using the SERDES
interfaces, you could have an external SGMII PHY connect to a
port. This would make sense with SFP cages, with a copper PHY inserted
into the cage. All ports of the 6390 allow this.

The hardware has two really separate MDIO busses. Both busses could
have a PHY on the same address. We should really model this as two
Linux MDIO devices.

It is actually a shame older chips don't have this. Early versions of
the ClearFog have a hardware design error. The external PHY on port6
is using address 0. So it clashes with the internal PHY on port0. Two
MDIO busses would solve this. And i actually expect quite a few
designs using the 6390 will put an external phy at address 0 and 1,
not 9 and 10. Few PHYs have that many strapping pins for address
selection.

     Andrew
