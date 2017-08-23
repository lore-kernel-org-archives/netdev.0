From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [RFC PATCH] dt-binding: net: sfp binding documentation
Date: Wed, 23 Aug 2017 15:16:53 +0300
Message-ID: <20170823121653.xha2obe4ewlhwyvh@sapphire.tkos.co.il>
References: <d73b635069a2054d110632f1f4196cd4bc281e7f.1503224886.git.baruch@tkos.co.il>
 <CAL_JsqL_7gG8FSEJDXu=37DFpHjfLhQuUhPFRKcScYTzM4cNyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Rutland <mark.rutland@arm.com>, Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Russell King <rmk+kernel@arm.linux.org.uk>,
        netdev <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Rob Herring <robh+dt@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:46644 "EHLO
        mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753793AbdHWMQ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Aug 2017 08:16:58 -0400
Content-Disposition: inline
In-Reply-To: <CAL_JsqL_7gG8FSEJDXu=37DFpHjfLhQuUhPFRKcScYTzM4cNyg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rob,

On Mon, Aug 21, 2017 at 02:10:33PM -0500, Rob Herring wrote:
> On Sun, Aug 20, 2017 at 5:28 AM, Baruch Siach <baruch@tkos.co.il> wrote:
> > Add device-tree binding documentation SFP transceivers. Support for SFP
> > transceivers has been recently introduced (drivers/net/phy/sfp.c).
> >
> > Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> > ---
> >
> > The SFP driver is on net-next.

[...]

> > +Optional Properties:
> > +
> > +- i2c-bus : phandle of an I2C bus controller for the SFP two wire serial
> > +  interface
> 
> Why not a child of the i2c bus it is on? IOW, what should this be a child of?

As I understand form the code the ID of the SFP i2c slave is derived from the 
Ethernet PHY 'reg' property. The PHY node's 'sfp' property points to a phandle 
of the sff,sfp node.

It is also possible for the 'sfp' property to appear directly in the Ethernet 
device node.

Quoting RMK from merge commit 234709336b8 (net-next):

    To add to the complexity, SFP modules can be connected in at least
    two places:
    
    1. Directly to the serdes output of a MAC with no intervening PHY.
       For example:
    
         mvneta ----> SFP socket
    
    2. To a PHY, for example:
    
         mvpp2 ---> PHY ---> copper
                     |
                     `-----> SFP socket
    
    This code supports both setups, although it's not fully implemented
    with scenario (2).

baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
