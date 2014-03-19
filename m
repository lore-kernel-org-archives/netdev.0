From: Byungho An <bh74.an@samsung.com>
Subject: RE: [PATCH V4 1/8] sxgbe: Add device-tree binding support document
Date: Wed, 19 Mar 2014 15:32:48 -0700
Message-ID: <00cd01cf43c3$2b086d50$811947f0$@samsung.com>
References: <00f801cf4275$e7e2a1b0$b7a7e510$@samsung.com>
 <20140318091852.GA8043@e106331-lin.cambridge.arm.com>
 <001101cf42c7$00d99ba0$028cd2e0$@samsung.com>
 <20140319150402.GC9188@e106331-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	devicetree@vger.kernel.org, davem@davemloft.net,
	ilho215.lee@samsung.com, siva.kallam@samsung.com,
	vipul.pandya@samsung.com, ks.giri@samsung.com
To: 'Mark Rutland' <mark.rutland@arm.com>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-reply-to: <20140319150402.GC9188@e106331-lin.cambridge.arm.com>
Content-language: en-us
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Rutland <mark.rutland@arm.com> :
> On Tue, Mar 18, 2014 at 04:27:46PM +0000, Byungho An wrote:
> > Mark Rutland <mark.rutland@arm.com> :
> > > Hi,
> > >
> > > As a general note it's helpful for devicetree to be Cc'd on the
> > > entire
> > series
> > > (though the binding document should be a separate patch) as it
> > > provides
> > useful
> > > context for reviewing the binding.
> > OK.
> >
> > >
> > > On Tue, Mar 18, 2014 at 06:47:13AM +0000, Byungho An wrote:
> > > > From: Siva Reddy <siva.kallam@samsung.com>
> > > >
> > > > This patch adds binding document for SXGBE ethernet driver via
> > device-tree.
> > > >
> > > > Signed-off-by: Siva Reddy Kallam <siva.kallam@samsung.com>
> > > > Signed-off-by: Byungho An <bh74.an@samsung.com>
> > > > ---
> > > >  .../devicetree/bindings/net/samsung-sxgbe.txt      |   53
> > > > ++++++++++++++++++++
> > > >  1 file changed, 53 insertions(+)
> > > >  create mode 100644
> > > > Documentation/devicetree/bindings/net/samsung-sxgbe.txt
> > > >
> > > > diff --git
> > > > a/Documentation/devicetree/bindings/net/samsung-sxgbe.txt
> > > > b/Documentation/devicetree/bindings/net/samsung-sxgbe.txt
> > > > new file mode 100644
> > > > index 0000000..ca27947
> > > > --- /dev/null
> > > > +++ b/Documentation/devicetree/bindings/net/samsung-sxgbe.txt
> > > > @@ -0,0 +1,53 @@
> > > > +* Samsung 10G Ethernet driver (SXGBE)
> > > > +
> > > > +Required properties:
> > > > +- compatible: Should be "samsung,sxgbe-v2.0a"
> > > > +- reg: Address and length of the register set for the device
> > > > +- interrupt-parent: Should be the phandle for the interrupt
> > > > +controller
> > > > +  that services interrupts for this device
> > > > +- interrupts: Should contain the SXGBE interrupts
> > > > +  These interrupts are ordered by fixed and follows variable
> > > > +  trasmit DMA interrupts, receive DMA interrupts and lpi interrupt.
> > > > +  index 0 - this is fixed common interrupt of SXGBE and it is
> > > > +always
> > > > +  available.
> > > > +  index 1 to 25 - 8 variable trasmit interrupts, variable 16
> > > > +receive
> > > > interrupts
> > > > +  and 1 optional lpi interrupt.
> > > > +- phy-mode: String, operation mode of the PHY interface.
> > > > +  Supported values are: "xaui", "gmii".
> > > > +- samsung,pbl: Integer, Programmable Burst Length.
> > > > +  Supported values are 1, 2, 4, 8, 16, or 32.
> > >
> > > There's no need to abbreviate to "pbl".
> > >
> > > Is this a property of the hardware, or configuration that the kernel
> > > will
> > program
> > > in? If the latter, why can the kernel not choose?
> > Yes, this is hardware property
> 
> Ok.
> 
> >
> > >
> > > > +- samsung,fixed-burst: Boolean, Program the DMA to use the fixed
> > > > +burst mode
> > > > +- samsung,burst-map: Integer, Program the possible bursts
> > > > +supported by sxgbe
> > > > +  This is an interger and represents allowable DMA bursts when
> > > > +fixed
> > burst.
> > > > +  Allowable range is 0x00-0x3F. This field is valid only when
> > > > +fixed burst is
> > > > +  enabled, otherwise ignored.
> > >
> > > If that's the case, why not have just this property and have it
> > > imply the
> > use of
> > > fixed burst mode?
> > OK. It will be implemented in next patch set.
> >
> > >
> > > When is it necessary to use fixed burst mode?
> > This is the configurable mode of DMA an used internally by hardware to
> > fetch data from platform bus
> 
> Sure, but that doesn't describe when it is necessary. Is this the way the
DMA
> was configured at integration time, or the way the kernel should configure
it?
It is needed when fixed length of burst is needed. 
if it is not configured, the length of burst will be variable(not fixed).
Anyway, I'll add description more for it.

> 
> If the latter, is it absolutely necessary for correctness to use fixed-burst
mode?
> Or is it just always sensible to use it if available? 
It is not absolutely necessary, as I mentioned above.

> 
> What does the driver do if fixed burst mode is not available? Would this
work in
> the presence of fixed-burt mode?
Fixed burst mode is always available so driver doesn't need to care about it.

> 
> I'm not arguing to remove these properties. I'd just like to understand if
all
> you're describing is the presence of a feature or that the use of the
feature is
> absolutely necessary for correctness.
OK

> 
> I'm perfectly happy for Linux to always decide to use these features if
available.
> 
> >
> > >
> > > > +- samsung,adv-addr-mode: Boolean, Program the DMA to use Enhanced
> > > > +address
> > > > mode.
> > >
> > > When would this be selected, and why can the kernel not choose?
> > Kernel doesn't have the provision to find out a way to select this.
> > So, need to pass from DT
> 
> Likewise, it is always absolutely necessary, or just always sensible to use
> enhanced address mode if present?
Not always necessary. When extended address mode is needed, it can be set in
the DT.

> 
> >
> > >
> > > > +- samsung,force_thresh_dma_mode: Boolean, Force DMA to use the
> > > > +threshold mode
> > > > +  for both tx and rx
> > >
> > > s/_/-/ in property names.
> > OK.
> >
> > >
> > > Likewise, why can the kernel not choose.
> > SXGBE h/w registers can't provide information to select this. So, need
> > to pass from DT depend on Platform
> 
> Similarly.
Not always necessary. When threshold base DMA mode is needed it can be set.

> 
> >
> > >
> > > > +- samsung,force_sf_dma_mode: Boolean, Force DMA to use the Store
> > > > +and Forward
> > > > +  mode for both tx and rx. This flag is ignored if
> > > > +force_thresh_dma_mode is
> > > > set.
> > >
> > > Likewise for both points.
> > Same above.
> 
> And again.
Not always necessary. When threshold base DMA mode is not needed it can be
set.
On the other hand, store and forward is needed for DMA, it can be set.

Thanks,
> 
> Cheers,
> Mark.
