From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH] dt-binding: net: sfp binding documentation
Date: Wed, 23 Aug 2017 15:10:51 +0200
Message-ID: <20170823131051.GD28612@lunn.ch>
References: <d73b635069a2054d110632f1f4196cd4bc281e7f.1503224886.git.baruch@tkos.co.il>
 <CAL_JsqL_7gG8FSEJDXu=37DFpHjfLhQuUhPFRKcScYTzM4cNyg@mail.gmail.com>
 <20170823121653.xha2obe4ewlhwyvh@sapphire.tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Russell King <rmk+kernel@arm.linux.org.uk>,
        netdev <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40930 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753953AbdHWNLA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Aug 2017 09:11:00 -0400
Content-Disposition: inline
In-Reply-To: <20170823121653.xha2obe4ewlhwyvh@sapphire.tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 23, 2017 at 03:16:53PM +0300, Baruch Siach wrote:
> Hi Rob,
> 
> On Mon, Aug 21, 2017 at 02:10:33PM -0500, Rob Herring wrote:
> > On Sun, Aug 20, 2017 at 5:28 AM, Baruch Siach <baruch@tkos.co.il> wrote:
> > > Add device-tree binding documentation SFP transceivers. Support for SFP
> > > transceivers has been recently introduced (drivers/net/phy/sfp.c).
> > >
> > > Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> > > ---
> > >
> > > The SFP driver is on net-next.
> 
> [...]
> 
> > > +Optional Properties:
> > > +
> > > +- i2c-bus : phandle of an I2C bus controller for the SFP two wire serial
> > > +  interface
> > 
> > Why not a child of the i2c bus it is on? IOW, what should this be a child of?
> 
> As I understand form the code the ID of the SFP i2c slave is derived from the 
> Ethernet PHY 'reg' property. The PHY node's 'sfp' property points to a phandle 
> of the sff,sfp node.

Hi Rob

The SFP module uses multiple addresses on the i2c bus. 0x50 is
something like an EEPROM, but some of the content is
dynamic. Depending of the version of the standard, it can also use
0x51 for additional information. If the SPF module contains a copper
PHY, it also uses another address on the i2c bus for the standard
copper PHY registers.

An SFP module does not fit the usual I2C client model, since it is a
collection of interconnected i2c clients in one package.

	   Andrew
