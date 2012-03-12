From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH] stmmac: Add device-tree support
Date: Mon, 12 Mar 2012 16:06:26 +0100
Message-ID: <201203121606.26926.sr@denx.de>
References: <1331561157-3820-1-git-send-email-sr@denx.de> <4F5E0993.9020000@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Viresh Kumar <viresh.kumar@st.com>,
	devicetree-discuss@ozlabs.org, linux-arm-kernel@lists.infradead.org
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.182]:50833 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753116Ab2CLPGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 11:06:54 -0400
In-Reply-To: <4F5E0993.9020000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rob,

On Monday 12 March 2012 15:34:59 Rob Herring wrote:
> On 03/12/2012 09:05 AM, Stefan Roese wrote:
> > This patch adds support to configure the STMMAC ethernet driver via
> > device-tree instead of platform_data.
> > 
> > Currently, only the properties needed on SPEAr600 are provided. All
> > other properties should be added once needed on other platforms.
> > 
> > Signed-off-by: Stefan Roese <sr@denx.de>
> > Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> > Cc: Viresh Kumar <viresh.kumar@st.com>
> > ---
> > 
> >  Documentation/devicetree/bindings/net/stmmac.txt   |   38 +++++++++++
> >  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   66
> >  +++++++++++++++++++- 2 files changed, 103 insertions(+), 1 deletion(-)
> >  create mode 100644 Documentation/devicetree/bindings/net/stmmac.txt
> > 
> > diff --git a/Documentation/devicetree/bindings/net/stmmac.txt
> > b/Documentation/devicetree/bindings/net/stmmac.txt new file mode 100644
> > index 0000000..386a47f
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> > @@ -0,0 +1,38 @@
> > +* STMicroelectronics 10/100/1000 Ethernet driver (GMAC)
> > +
> > +Required properties:
> > +- compatible: Should be "stm,gmac"
> 
> This is too generic. This should be 1 string per version of h/w.

Viresh, Giuseppe, can you please suggest a proper string for the SPEAr600 
STMMAC core, including version?
 
> 'stm' should be 'st' according to vendor-prefixes.txt.

Okay.
 
> > +- reg: Address and length of the register set for the device
> > +- interrupt-parent: Should be the phandle for the interrupt controller
> > +  that services interrupts for this device
> > +- interrupts: Should contain the STMMAC interrupts
> > +- interrupt-names: Should contain the interrupt names "macirq"
> > +  "eth_wake_irq" if this interrupt is supported in the "interrupts"
> > +  property
> 
> You should be able to tell this from the compatible string and number of
> interrupts.

Yes. Currently the driver uses platform_get_irq_byname() to register the 
irq's. That's why I added these properties. Is there something wrong with 
using it this way?
 
> > +- phy-mode: String, operation mode of the PHY interface.
> > +  Supported values are: "mii", "rmii", "gmii", "rgmii".
> > +- phy-addr: MDIO address of the PHY
> 
> This is normally probed or the mdio bus is a sub-node of the MAC node.
> See arch/powerpc/boot/dts/mpc8377_mds.dts for an example.

Okay, I'll rework this.

> > +
> > +Optional properties:
> > +- stm,prog-burst-len: Specify the burst length
> > +- stm,has-gmac: Indicates that the controller supports 1000Mbps
> > +- stm,has-pmt: Indicates that the controller supports power management
> 
> I think these should all be encoded by the compatible string.

You mean that by defining a specific compatible string (e.g.
"st,gmac-spear600"), these settings are implicitly set? And should therefore 
be omitted from the dts?

Thanks,
Stefan
