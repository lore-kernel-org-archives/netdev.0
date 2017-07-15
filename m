From: Moritz Fischer <mdf@kernel.org>
Subject: Re: [PATCH v2 1/2] dt-bindings: net: Add bindings for National
 Instruments XGE netdev
Date: Sat, 15 Jul 2017 11:46:53 -0700
Message-ID: <20170715184653.GA28599@tyrael.ni.corp.natinst.com>
References: <1500065326-26182-1-git-send-email-mdf@kernel.org>
 <20170715183745.GA28217@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Moritz Fischer <mdf@kernel.org>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, mark.rutland@arm.com, robh+dt@kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170715183745.GA28217@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

On Sat, Jul 15, 2017 at 08:37:45PM +0200, Andrew Lunn wrote:
> On Fri, Jul 14, 2017 at 01:48:45PM -0700, Moritz Fischer wrote:
> > This adds bindings for the NI XGE 1G/10G network device.
> > 
> > Signed-off-by: Moritz Fischer <mdf@kernel.org>
> > ---
> >  Documentation/devicetree/bindings/net/nixge.txt | 32 +++++++++++++++++++++++++
> >  1 file changed, 32 insertions(+)
> >  create mode 100644 Documentation/devicetree/bindings/net/nixge.txt
> > 
> > diff --git a/Documentation/devicetree/bindings/net/nixge.txt b/Documentation/devicetree/bindings/net/nixge.txt
> > new file mode 100644
> > index 0000000..9fff5a7
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/nixge.txt
> > @@ -0,0 +1,32 @@
> > +* NI XGE Ethernet controller
> > +
> > +Required properties:
> > +- compatible: Should be "ni,xge-enet-2.00"
> > +- reg: Address and length of the register set for the device
> > +- interrupts: Should contain tx and rx interrupt
> > +- interrupt-names: Should be "rx-irq" and "tx-irq"
> > +- phy-mode: See ethernet.txt file in the same directory.
> 
> Hi Moritz
> 
> phy-handle is now required.

Good catch, thanks.
> 
> > +Examples (10G generic PHY):
> > +	nixge0: ethernet@40000000 {
> > +		compatible = "ni,xge-enet-2.00";
> > +		reg = <0x40000000 0x6000>;
> > +
> > +		nvmem-cells = <&eth1_addr>;
> > +		nvmem-cell-names = "address";
> > +
> > +		interrupts = <0 29 4>, <0 30 4>;
> 
> IRQ_TYPE_LEVEL_HIGH

Sure, will do.
> 
> > +		interrupt-names = "rx-irq", "tx-irq";
> > +		interrupt-parent = <&intc>;
> > +
> > +		phy-mode = "xgmii";
> > +		phy-handle = <&ethernet_phy1>;
> > +
> > +		ethernet_phy1: ethernet-phy@4 {
> > +			compatible = "ethernet-phy-ieee802.3-c45";
> > +			reg = <4>;
> > +			devices = <0xa>;
> > +		};
> 
> Since you don't fully implement c45, does this example actually work?

Yeah, I've tested this continuously. But for v3 I anyways implmented c45
writes.

> And devices is not a standard phy property.
> 

Will fix.
>     Andrew

Cheers,

Moritz
