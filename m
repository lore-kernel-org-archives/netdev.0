From: Chen Baozi <baozich@gmail.com>
Subject: Re: [PATCH 3/3] stmmac: Add AXI burst length support to platform
 device.
Date: Wed, 11 Feb 2015 19:11:00 +0800
Message-ID: <20150211111100.GA23290@cbz-thinkpad>
References: <20150210020734.GE7920@cbz-thinkpad>
 <20150210114837.GC6659@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150210114837.GC6659@leverpostej>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 10, 2015 at 11:48:37AM +0000, Mark Rutland wrote:
> > On Mon, Feb 09, 2015 at 12:04:43PM +0000, Mark Rutland wrote:
> > > On Sat, Feb 07, 2015 at 05:07:16AM +0000, Chen Baozi wrote:
> > > > The AXI Bus Mode Register controls the AXI master behavior. It is mainly
> > > > used to control the burst splitting and the number of outstanding requests.
> > > > This register is present and valid only in GMAC-AXI configuration. The old
> > > > driver only supports this feature on PCI devices. This patch adds an
> > > > 'snps,apl' properties in DT to enable it on platform devices.
> > > > 
> > > > Signed-off-by: Chen Baozi <chenbaozi@kylinos.com.cn>
> > > > ---
> > > >  Documentation/devicetree/bindings/net/stmmac.txt      | 1 +
> > > >  drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 1 +
> > > >  2 files changed, 2 insertions(+)
> > > > 
> > > > diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
> > > > index c41afd9..8f3c834 100644
> > > > --- a/Documentation/devicetree/bindings/net/stmmac.txt
> > > > +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> > > > @@ -43,6 +43,7 @@ Optional properties:
> > > >    available this clock is used for programming the Timestamp Addend Register.
> > > >    If not passed then the system clock will be used and this is fine on some
> > > >    platforms.
> > > > +- snps,abl: AXI Burst Length
> > > 
> > > This is not a good name (though I see it follows "snps,pbl", which is
> > > also not a good name)...
> > 
> > Any idea for a better name?
> 
> Perhaps snps,axi-burst-length ?
> 
> > > Why does this need to be in the DT? Is this required for correctness? Or
> > > performance?
> > 
> > This is required for correctness. Otherwise, the driver would write
> > '0' to the register by default, which makes the driver not work.
> 
> What does that mean at the HW level? If that won't work in all cases
> why does the driver do that?

According to the manual, this is used to select the burst length on AXI
master interface. The register is optional and valid only in GMAC-AXI
configuration. IMHO, not all cases require the driver to set this
register. So I just put it in the 'optional properties', in case some
devices depend on that.

Cheers,

Baozi.
