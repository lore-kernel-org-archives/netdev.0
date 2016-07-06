From: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>
Subject: RE: [RFC PATCH v2 1/4] Documentation: DT: net: Add Xilinx
 gmiitorgmii converter device tree binding documentation
Date: Wed, 6 Jul 2016 14:12:21 +0000
Message-ID: <03CA77BA8AF6F1469AEDFBDA1322A7B74A193913@XAP-PVEXMBX02.xlnx.xilinx.com>
References: <1467623084-15471-1-git-send-email-appanad@xilinx.com>
 <1467623084-15471-2-git-send-email-appanad@xilinx.com>
 <20160704140458.GC3282@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "robh+dt@kernel.org" <robh+dt@kernel.org>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	Michal Simek <michals@xilinx.com>,
	Soren Brinkmann <sorenb@xilinx.com>,
	"nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	Harini Katakam <harinik@xilinx.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Appana Durga Kedareswara Rao <appanad@xilinx.com>
To: Andrew Lunn <andrew@lunn.ch>,
	Appana Durga Kedareswara Rao <appanad@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160704140458.GC3282@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Monday, July 04, 2016 7:35 PM
> To: Appana Durga Kedareswara Rao <appanad@xilinx.com>
> Cc: robh+dt@kernel.org; mark.rutland@arm.com; Michal Simek
> <michals@xilinx.com>; Soren Brinkmann <sorenb@xilinx.com>; Punnaiah
> Choudary Kalluri <punnaia@xilinx.com>; nicolas.ferre@atmel.com;
> f.fainelli@gmail.com; Anirudha Sarangi <anirudh@xilinx.com>; Harini
> Katakam <harinik@xilinx.com>; netdev@vger.kernel.org;
> devicetree@vger.kernel.org; linux-arm-kernel@lists.infradead.org; linux-
> kernel@vger.kernel.org; Appana Durga Kedareswara Rao
> <appanad@xilinx.com>
> Subject: Re: [RFC PATCH v2 1/4] Documentation: DT: net: Add Xilinx
> gmiitorgmii converter device tree binding documentation
> 
> On Mon, Jul 04, 2016 at 02:34:41PM +0530, Kedareswara rao Appana wrote:
> > Device-tree binding documentation for xilinx gmiitorgmii converter.
> >
> > Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
> > ---
> > Changes for v2:
> > --> New patch.
> >
> >  .../devicetree/bindings/net/xilinx_gmii2rgmii.txt  | 31
> ++++++++++++++++++++++
> >  1 file changed, 31 insertions(+)
> >  create mode 100644
> Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt
> >
> > diff --git a/Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt
> b/Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt
> > new file mode 100644
> > index 0000000..d11e259
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt
> > @@ -0,0 +1,31 @@
> > +* XILINX GMIITORGMII Converter Driver
> > +
> > +The Gigabit Media Independent Interface (GMII) to Reduced Gigabit
> Media
> > +Independent Interface (RGMII) core provides the RGMII between RGMII-
> compliant
> > +Ethernet physical media devices (PHY) and the Gigabit Ethernet controller.
> > +This core can be used in all three modes of operation(10/100/1000 Mb/s).
> > +The Management Data Input/Output (MDIO) interface is used to
> configure the
> > +Speed of operation. This core can switch dynamically between the three
> > +Different speed modes by configuring the conveter register through mdio
> write.
> > +
> > +The MDIO is a bus to which the PHY devices are connected.  For each
> > +device that exists on this bus, a child node should be created.  See
> > +the definition of the PHY node in booting-without-of.txt for an example
> > +of how to define a PHY.
> > +
> > +Required properties:
> > +  - compatible : Should be "xlnx,gmiitorgmii"
> > +  - reg : The ID number for the phy, usually a small integer
> > +
> > +Example:
> > +	mdio {
> > +                #address-cells = <1>;
> > +                #size-cells = <0>;
> > +		ethernet-phy@0 {
> > +			......
> > +		};
> > +                gmii_to_rgmii: gmii_to_rgmii@8 {
> > +                        compatible = "xlnx,gmiitorgmii";
> > +                        reg = <8>;
> > +                };
> > +        };
> 
> Hi Kedareswara
> 
> So looking at the device tree, you have the gmiitorgmii as an mdio
> device. It will get probed as an mdio device, and from that you know
> the address on the bus. However, your driver does not actually do
> this. xilinx_gmii2rgmii.c is just a library of two functions, and does
> not use any of this device tree information. You device tree binding
> is completely bogus.
> 
> What i think is a much more logical structure, and fits the hardware,
> which is what DT is all about, is to make your driver an mdio driver.
> Also, have a phy-handle pointing to the PHY in the gmii_to_rgmii node.
> You then no longer need the exported gmii2rgmii_phyprobe() function.
> 
> Next, you want gmiitorgmii driver to register a phy. The MAC driver
> can then look this up using phy-handle:
> 
>        mdio {
>                 #address-cells = <1>;
>                 #size-cells = <0>;
> 
>                 phy: ethernet-phy@0 {
>                         reg = <0>;
>                 };
> 
>                 gmii_to_rgmii: gmii-to-rgmii@8 {
>                         compatible = "xlnx,gmiitorgmii";
>                         reg = <8>;
> 			phy-handle = <&phy>;
>                 };
>        };


Thanks for your inputs initially we too thought the similar implementation
But the GMII2RGMII converter contains only one register and it is 
 not compatible to the standard ethernet MII interface. Also it doesn't have
a standard VID and PID registers So, during the mdio bus scan, this device will 
not appear. When macb driver calls the gmii2rgmii phy-handle through
 phy_connect_direct/of_phy_connect, these calls fail for the above reason.
So, we come up with the current implementation.

Please suggest if you have any other solutions in mind or if our understanding 
is wrong for the current approach that you suggested.

Regards,
Punnaiah

> 
>         macb0: ethernet@fffc4000 {
>                 compatible = "cdns,at32ap7000-macb";
>                 reg = <0xfffc4000 0x4000>;
>                 interrupts = <21>;
>                 phy-mode = "rmii";
> 		phy-handle = <&gmii_to_rgmii>
>                 local-mac-address = [3a 0e 03 04 05 06];
>                 clock-names = "pclk", "hclk", "tx_clk";
>                 clocks = <&clkc 30>, <&clkc 30>, <&clkc 13>;
>                 ethernet-phy@1 {
>                         reg = <0x1>;
>                         reset-gpios = <&pioE 6 1>;
>                 };
>         };
> 
> This description is the same as the figure in the data sheet. You have
> the gmii_to_rgmii which passes through to the real PHY.
> 
> The phy device that gmiitorgmii registers needs to pass through all
> its operations to the real PHY. The exception is read_status()
> function. You want to wrap this, so that after it completes and you
> know the speed the PHY is using, you set the same speed in your
> gmiitorgmii device.
> 
> Everything then becomes transparent. There is no need to change the
> MAC driver, and you have a generic solution which will work with any
> MAC and PHY.
> 
>     Andrew
