From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/8] net: dsa: mv88e6xxx: Implement external
 MDIO bus on mv88e6390
Date: Sat, 21 Jan 2017 17:15:32 +0100
Message-ID: <20170121161532.GB7808@lunn.ch>
References: <1484955062-26718-1-git-send-email-andrew@lunn.ch>
 <1484955062-26718-2-git-send-email-andrew@lunn.ch>
 <878tq5ffcc.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40599 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750735AbdAUQQa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 21 Jan 2017 11:16:30 -0500
Content-Disposition: inline
In-Reply-To: <878tq5ffcc.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 20, 2017 at 07:04:35PM -0500, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> > The mv88e6390 has two MDIO busses. The internal MDIO bus is used for
> > the internal PHYs. The external MDIO can be used for external PHYs.
> > The external MDIO bus will be instantiated if there is an
> > "mdio-external" node in the device tree.
> 
> Thanks for pushing the 88E6390 support. Some comments below.
> 
> > +static int mv88e6xxx_read_phy(struct mv88e6xxx_chip *chip, int addr, int reg,
> > +static int mv88e6xxx_write_phy(struct mv88e6xxx_chip *chip, int addr, int reg,
> >  static int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy,
> >  static int mv88e6xxx_phy_write(struct mv88e6xxx_chip *chip, int phy,
> 
> Adding mv88e6xxx_read/write_phy() in addition to existing
> mv88e6xxx_phy_read/write() feels really confusing and hard to
> maintain. Can that be done the other way around maybe?

Yes, i agree. I didn't particularly like it either. What might be
simpler is to pass the struct mii_bus all the way down, where as we
only currently have chip.

     Andrew
