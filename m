From: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>
Subject: RE: [RFC PATCH v2 1/4] Documentation: DT: net: Add Xilinx
 gmiitorgmii converter device tree binding documentation
Date: Wed, 6 Jul 2016 14:51:28 +0000
Message-ID: <03CA77BA8AF6F1469AEDFBDA1322A7B74A19393B@XAP-PVEXMBX02.xlnx.xilinx.com>
References: <1467623084-15471-1-git-send-email-appanad@xilinx.com>
 <1467623084-15471-2-git-send-email-appanad@xilinx.com>
 <20160704140458.GC3282@lunn.ch>
 <03CA77BA8AF6F1469AEDFBDA1322A7B74A193913@XAP-PVEXMBX02.xlnx.xilinx.com>
 <20160706142121.GI19800@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "mark.rutland@arm.com" <mark.rutland@arm.com>,
 Harini Katakam <harinik@xilinx.com>,
 "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
 "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "robh+dt@kernel.org" <robh+dt@kernel.org>, Michal
 Simek <michals@xilinx.com>, Soren Brinkmann <sorenb@xilinx.com>,
 Anirudha Sarangi <anirudh@xilinx.com>,
 Appana Durga Kedareswara Rao <appanad@xilinx.com>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20160706142121.GI19800@lunn.ch>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Wednesday, July 06, 2016 7:51 PM
> To: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
> Cc: Appana Durga Kedareswara Rao <appanad@xilinx.com>;
> robh+dt@kernel.org; mark.rutland@arm.com; Michal Simek
> <michals@xilinx.com>; Soren Brinkmann <sorenb@xilinx.com>;
> nicolas.ferre@atmel.com; f.fainelli@gmail.com; Anirudha Sarangi
> <anirudh@xilinx.com>; Harini Katakam <harinik@xilinx.com>;
> netdev@vger.kernel.org; devicetree@vger.kernel.org; linux-arm-
> kernel@lists.infradead.org; linux-kernel@vger.kernel.org
> Subject: Re: [RFC PATCH v2 1/4] Documentation: DT: net: Add Xilinx
> gmiitorgmii converter device tree binding documentation
> 
> > > Hi Kedareswara
> > >
> > > So looking at the device tree, you have the gmiitorgmii as an mdio
> > > device. It will get probed as an mdio device, and from that you know
> > > the address on the bus. However, your driver does not actually do
> > > this. xilinx_gmii2rgmii.c is just a library of two functions, and does
> > > not use any of this device tree information. You device tree binding
> > > is completely bogus.
> > >
> > > What i think is a much more logical structure, and fits the hardware,
> > > which is what DT is all about, is to make your driver an mdio driver.
> > > Also, have a phy-handle pointing to the PHY in the gmii_to_rgmii node.
> > > You then no longer need the exported gmii2rgmii_phyprobe() function.
> > >
> > > Next, you want gmiitorgmii driver to register a phy. The MAC driver
> > > can then look this up using phy-handle:
> > >
> > >        mdio {
> > >                 #address-cells = <1>;
> > >                 #size-cells = <0>;
> > >
> > >                 phy: ethernet-phy@0 {
> > >                         reg = <0>;
> > >                 };
> > >
> > >                 gmii_to_rgmii: gmii-to-rgmii@8 {
> > >                         compatible = "xlnx,gmiitorgmii";
> > >                         reg = <8>;
> > > 			phy-handle = <&phy>;
> > >                 };
> > >        };
> >
> >
> > Thanks for your inputs initially we too thought the similar implementation
> > But the GMII2RGMII converter contains only one register and it is
> >  not compatible to the standard ethernet MII interface. Also it doesn't have
> > a standard VID and PID registers So, during the mdio bus scan, this device
> will
> > not appear.
> 
> Hi Punnaiah
> 
> Use missed some subtlety in my description. I did not call the
> GMII2RGMII a PHY device, i called it an MDIO device. These are
> different things. Go look at the MDIO subsystem to figure out the
> difference.
> 
Hi Andrew

Got it. Thanks.

Punnaiah

> 	Andrew
