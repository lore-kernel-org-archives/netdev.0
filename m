From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: adds backplane driver for Freescale's PCS PHY
Date: Tue, 22 Dec 2015 11:43:02 +0100
Message-ID: <20151222104302.GB2373@lunn.ch>
References: <1450431054-5227-1-git-send-email-shh.xie@gmail.com>
 <20151218120209.GA477@lunn.ch>
 <VI1PR04MB166411C52B56AE738706F407E8E40@VI1PR04MB1664.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "shh.xie@gmail.com" <shh.xie@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	Xie Shaohui-B21989 <Shaohui.Xie@freescale.com>
To: Shaohui Xie <shaohui.xie@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47742 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750772AbbLVKnF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Dec 2015 05:43:05 -0500
Content-Disposition: inline
In-Reply-To: <VI1PR04MB166411C52B56AE738706F407E8E40@VI1PR04MB1664.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I did missed the device tree binding documentation.
> This driver expected a property "lane-instance" in mdio bus node, and
> "lane-handle" and "lane-range" properties in phy node.
> 
> The "lane-instance" indicates what the phy should be probed as,
> 1000BASE-KX or 10GBASE-KR, seems phy node is a better place than mdio bus node
> to hold this property, maybe a better name "phy-mode" should be used?

Ideally you want all the properties in the phy node. It can get
complicated, if you have an mdio mux in the chain. Extending phy-mode
would make, rather than adding a new property.

> 
> The "lane-handle" pointed to a serdes node which looks like below:
> E.g. in arch/powerpc/boot/dts/fsl/t4240si-post.dtsi:
> 
>         serdes: serdes@ea000 {
>                 compatible = "fsl,t4240-serdes";
>                 reg        = <0xea000 0x4000>;
>         };
> 
> The "lane-handle" property would be: lane-handle = <&serdes>;

There does not appear to be a driver which uses fsl,t4240-serdes?  Is
there a driver for it? Ah, this is the driver right? It maps the io
space and uses the registers in that space.

So there is an architectural question. Should there be a separate
serdes driver, or is it O.K. to include the serdes driver within the
phy driver?

Is the PHY embedded inside the Soc? Or is it discrete? Could the same
phy be used with a different MAC/serdes interface?

    Andrew
