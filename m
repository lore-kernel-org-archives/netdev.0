From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 1/8] net: smc91x: Fix device tree based configuration
 so it's usable
Date: Thu, 14 Nov 2013 08:08:13 -0800
Message-ID: <20131114160813.GC10317@atomide.com>
References: <1384396537-3486-1-git-send-email-tony@atomide.com>
 <1384396537-3486-2-git-send-email-tony@atomide.com>
 <20131114110324.GC16396@e106331-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	Nicolas Pitre <nico@fluxnic.net>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131114110324.GC16396@e106331-lin.cambridge.arm.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Mark Rutland <mark.rutland@arm.com> [131114 03:04]:
> On Thu, Nov 14, 2013 at 02:35:30AM +0000, Tony Lindgren wrote:
> > Commit 89ce376c6bdc (drivers/net: Use of_match_ptr() macro in smc91x.c)
> > added minimal device tree support to smc91x, but it's not working on
> > many platforms because of the lack of some key configuration bits.
> > 
> > Fix the issue by parsing the necessary configuration like the
> > smc911x driver is doing.
> > 
> > Cc: Nicolas Pitre <nico@fluxnic.net>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Cc: netdev@vger.kernel.org
> > Cc: devicetree@vger.kernel.org
> > Signed-off-by: Tony Lindgren <tony@atomide.com>
> > ---
> > 
> > If this looks OK, I'd like to merge this as a fix via arm-soc tree
> > along with the other patches in this series as my later patches
> > depend on patches in this series.
> > 
> > ---
> >  .../devicetree/bindings/net/smsc-lan91c111.txt     |  4 ++
> >  drivers/net/ethernet/smsc/smc91x.c                 | 52 +++++++++++++++++-----
> >  2 files changed, 46 insertions(+), 10 deletions(-)
> > 
> > diff --git a/Documentation/devicetree/bindings/net/smsc-lan91c111.txt b/Documentation/devicetree/bindings/net/smsc-lan91c111.txt
> > index 953049b..53d69e3 100644
> > --- a/Documentation/devicetree/bindings/net/smsc-lan91c111.txt
> > +++ b/Documentation/devicetree/bindings/net/smsc-lan91c111.txt
> > @@ -8,3 +8,7 @@ Required properties:
> >  Optional properties:
> >  - phy-device : phandle to Ethernet phy
> >  - local-mac-address : Ethernet mac address to use
> > +- reg-io-width : Specify the size (in bytes) of the IO accesses that
> > +  should be performed on the device.  Valid value for SMSC LAN is
> > +  1, 2 or 4.  If it's omitted or invalid, the size would be 2.
> 
> In the driver the supported access sizes are not mutually exclusive.  It
> would be nice for the binding to have the same property.

Hmm indeed. How about we add reg-io-width-mask:

	1 = 8-bit access
	2 = 16-bit access
	4 = 32-bit access
	...

So for a driver to support 8, 16 and 32-bit access the mask would
be:
	reg-io-width-mask = <7>;

Although the values for reg-io-width would support masks too, it
might be better to have reg-io-width-mask to avoid confusion.

Or do you have any better ideas?
 
> > +- smsc,nowait : Setup for fast register access with no waits
> 
> I'm confused by what this means. When would this be selected, and when
> wouldn't it be?

The driver has a module parameter for it and the comments say:

"nowait  = 0 for normal wait states, 1 eliminates additional wait states"

Most platforms seem to set it, but the default is to not set it.
I guess we could that be a module parameter for now as that's a
timing optimization.

Regards,

Tony
