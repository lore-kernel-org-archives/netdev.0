From: Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [RFC PATCH] dt-binding: net: sfp binding documentation
Date: Wed, 23 Aug 2017 14:56:29 +0100
Message-ID: <20170823135629.GT20805@n2100.armlinux.org.uk>
References: <d73b635069a2054d110632f1f4196cd4bc281e7f.1503224886.git.baruch@tkos.co.il>
 <CAL_JsqL_7gG8FSEJDXu=37DFpHjfLhQuUhPFRKcScYTzM4cNyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAL_JsqL_7gG8FSEJDXu=37DFpHjfLhQuUhPFRKcScYTzM4cNyg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2017 at 02:10:33PM -0500, Rob Herring wrote:
> On Sun, Aug 20, 2017 at 5:28 AM, Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org> wrote:
> > Add device-tree binding documentation SFP transceivers. Support for SFP
> > transceivers has been recently introduced (drivers/net/phy/sfp.c).
> >
> > Signed-off-by: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
> > ---
> >
> > The SFP driver is on net-next.
> >
> > Not sure about the rate-select-gpio property name. The SFP+ standard
> > (not supported yet) uses two signals, RS0 and RS1. RS0 is compatible
> > with the SFP rate select signal, while RS1 controls the Tx rate.
> > ---
> >  Documentation/devicetree/bindings/net/sff-sfp.txt | 24 +++++++++++++++++++++++
> >  1 file changed, 24 insertions(+)
> >  create mode 100644 Documentation/devicetree/bindings/net/sff-sfp.txt
> >
> > diff --git a/Documentation/devicetree/bindings/net/sff-sfp.txt b/Documentation/devicetree/bindings/net/sff-sfp.txt
> > new file mode 100644
> > index 000000000000..f0c27bc3925e
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/sff-sfp.txt
> > @@ -0,0 +1,24 @@
> > +Small Form Factor (SFF) Committee Small Form-factor Pluggable (SFP)
> > +Transceiver
> > +
> > +Required properties:
> > +
> > +- compatible : must be "sff,sfp"
> 
> Need to document "sff" vendor prefix.
> 
> Kind of a short name, but I guess it is sufficient. Are there
> revisions of the standard (not SFP+) or more than one form factor (I
> don't recall any)?

The standards get revised and reorganised, so you can't really name any
particular standard.  SFP+ is a supplement to SFP, and I suspect that's
going to continue into the future.

> > +
> > +Optional Properties:
> > +
> > +- i2c-bus : phandle of an I2C bus controller for the SFP two wire serial
> > +  interface
> 
> Why not a child of the i2c bus it is on? IOW, what should this be a child of?

What reg= value would you use to identify it?  There's no particular
I2C bus address.  There's an EEPROM on the actual module, and there
may be a PHY on the I2C bus (some PHYs include I2C as an alternative
way to speak to them other than MDIO.)

I2C couldn't probe these as they are effectively hotplugged.

However, there's also the question about why it should be a child of
the I2C bus - the I2C bus is just a means of communicating with and
identifying the module.  You could equally argue that it should be
a child of the GPIO controller, because that's how it's controlled.
You could also argue that it should be a child of the ethernet
interface, since that's the main data path.

> > +
> > +- moddef0-gpio : phandle of the MOD-DEF0 (AKA Mod_ABS) module presence input
> > +  gpio signal
> 
> mod-def0-gpios?

It all depends on the standard you read.  Some call it MOD_DEF0, Mod-DEF0,
Mod_ABS, and some call it MOD-DEF0.  And confusingly, some standards call
the binary combination of the three MOD-DEF signals "MOD-DEF 0"...
"MOD-DEF 7".  These signals come from the GBIC module era.  It's something
of a mess.

> > +
> > +- los-gpio : phandle of the Receiver Loss of Signal Indication input gpio
> > +  signal
> > +
> > +- tx-fault-gpio : phandle of the Module Transmitter Fault input gpio signal
> > +
> > +- tx-disable-gpio : phandle of the Transmitter Disable output gpio signal
> > +
> > +- rate-select-gpio : phandle of the Rx Signaling Rate Select (AKA RS0) output
> > +  gpio
> 
> -gpios is the preferred form for all of these.

Even if there's only _one_ - using the plural leads one to think that
you can list many GPIOs, which is not correct here.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
