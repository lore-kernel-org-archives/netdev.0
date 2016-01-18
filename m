From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/2] ne: DeviceTree support.
Date: Mon, 18 Jan 2016 16:08:34 +0100
Message-ID: <20160118150834.GC923@lunn.ch>
References: <1452874786-21202-1-git-send-email-ysato@users.sourceforge.jp>
 <20160116172226.GB9880@lunn.ch>
 <87d1szmki3.wl-ysato@users.sourceforge.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Yoshinori Sato <ysato@users.sourceforge.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87d1szmki3.wl-ysato@users.sourceforge.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 18, 2016 at 04:09:40PM +0900, Yoshinori Sato wrote:
> On Sun, 17 Jan 2016 02:22:26 +0900,
> Andrew Lunn wrote:
> > 
> > On Sat, Jan 16, 2016 at 01:19:45AM +0900, Yoshinori Sato wrote:
> > > Add basic device tree support.
> > > 
> > > Signed-off-by: Yoshinori Sato <ysato@users.sourceforge.jp>
> > > ---
> > >  Documentation/devicetree/bindings/net/ne2000.txt | 17 +++++++++++++++++
> > >  drivers/net/ethernet/8390/ne.c                   | 20 +++++++++++++++++++-
> > >  2 files changed, 36 insertions(+), 1 deletion(-)
> > >  create mode 100644 Documentation/devicetree/bindings/net/ne2000.txt
> > > 
> > > diff --git a/Documentation/devicetree/bindings/net/ne2000.txt b/Documentation/devicetree/bindings/net/ne2000.txt
> > > new file mode 100644
> > > index 0000000..8b0dfbf
> > > --- /dev/null
> > > +++ b/Documentation/devicetree/bindings/net/ne2000.txt
> > > @@ -0,0 +1,17 @@
> > > +NE2000 compatible network controller
> > > +
> > > +Required properties:
> > > +- compatible: "national,ne2000"
> > > +- reg: base address and length of NE2000.
> > > +- interrupts: interrupt specifier for the sole interrupt.
> > > +- national,dcr: DCR setting value.
> > 
> > You say here that national,dcr is required, yet the code to read it is
> > not returning an error if it is missing.
> 
> Yes. This value required. Missing error check.
> 
> > Also, what is DCR?
> 
> This is chip configuration.
> It value depend on target design.

It needs to be described in detail what it is. Device tree bindings
generally don't list values to be poked into registers. They describe
something, and from that, the value to be poked into a register is
derived.

> > So there is a single DCR value, for all instances of the device?
> > The last device to probe wins?
> 
> Yes. It'll be usually the same value by all devices.

There is no 'usually' about it. You implementation forces them all to
be the same. You need to add error checking. If different DT instances
have different values, you need to issue an error and fail one or more
probes.

You also need to document this in the device tree binding.

	Andrew
