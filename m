From: Shaohui Xie <shaohui.xie@nxp.com>
Subject: RE: [PATCH] net: phy: adds backplane driver for Freescale's PCS PHY
Date: Tue, 22 Dec 2015 12:33:35 +0000
Message-ID: <VI1PR04MB1664255A7B6A19FCFB1F9646E8E50@VI1PR04MB1664.eurprd04.prod.outlook.com>
References: <1450431054-5227-1-git-send-email-shh.xie@gmail.com>
 <20151218120209.GA477@lunn.ch>
 <VI1PR04MB166411C52B56AE738706F407E8E40@VI1PR04MB1664.eurprd04.prod.outlook.com>
 <20151222104302.GB2373@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shh.xie@gmail.com" <shh.xie@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	Xie Shaohui-B21989 <Shaohui.Xie@freescale.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0092.outbound.protection.outlook.com ([157.56.112.92]:63669
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750772AbbLVMdj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 07:33:39 -0500
In-Reply-To: <20151222104302.GB2373@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I did missed the device tree binding documentation.
> > This driver expected a property "lane-instance" in mdio bus node, and
> > "lane-handle" and "lane-range" properties in phy node.
> >
> > The "lane-instance" indicates what the phy should be probed as,
> > 1000BASE-KX or 10GBASE-KR, seems phy node is a better place than mdio
> > bus node to hold this property, maybe a better name "phy-mode" should
> be used?
> 
> Ideally you want all the properties in the phy node. It can get
> complicated, if you have an mdio mux in the chain. Extending phy-mode
> would make, rather than adding a new property.
[S.H] Yes, phy-mode is a better choice.

> 
> >
> > The "lane-handle" pointed to a serdes node which looks like below:
> > E.g. in arch/powerpc/boot/dts/fsl/t4240si-post.dtsi:
> >
> >         serdes: serdes@ea000 {
> >                 compatible = "fsl,t4240-serdes";
> >                 reg        = <0xea000 0x4000>;
> >         };
> >
> > The "lane-handle" property would be: lane-handle = <&serdes>;
> 
> There does not appear to be a driver which uses fsl,t4240-serdes?  Is
> there a driver for it? Ah, this is the driver right? It maps the io space
> and uses the registers in that space.
[S.H] There is no driver for fsl,t4240-serdes or any serdes, there are 
many SoCs have a serdes node (grep -r serdes arch/powerpc/boot/dts/).
Only some SoCs can support 1G-KX or 10G-KR, e.g. T4240, T2080, T1024, T1040.
Serdes may be different on different SoCs.

The phy driver needs to configure lane control registers at runtime 
to tune lane signal, but lane control registers are only a small part 
of serdes, there are many other registers for different functions.
It's not a driver for serdes.

> 
> So there is an architectural question. Should there be a separate serdes
> driver, or is it O.K. to include the serdes driver within the phy driver?
[S.H] A serdes driver might be too much, the phy driver only needs to use
Some lane control registers.

> 
> Is the PHY embedded inside the Soc? Or is it discrete? Could the same phy
> be used with a different MAC/serdes interface?
[S.H] Yes, the PHY embedded inside the SoC, each MAC has an internal MDIO 
Controller to access the internal PCS PHY, the same phy cannot be used with
a different MAC/serdes interface.

Thanks,
Shaohui
