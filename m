From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC net-next] of: mdio: Honor hints from MDIO bus drivers
Date: Thu, 13 Apr 2017 23:51:14 +0200
Message-ID: <20170413215114.GB29708@lunn.ch>
References: <20170410214258.9409-1-f.fainelli@gmail.com>
 <8ef102a4-22e5-def8-b50e-04f84b5849d7@gmail.com>
 <20170411231424.GA6174@lunn.ch>
 <6de72d4c-5634-f3d6-5bfd-fcc0acda0b83@gmail.com>
 <417fdaa1-7aba-e646-8a50-043322f1410d@gmail.com>
 <20170412221016.GA29708@lunn.ch>
 <6fdcec91-829b-70c9-8780-992b67f6831a@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>,
        "open list:OPEN FIRMWARE AND FLATTENED DEVICE TREE"
        <devicetree@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58049 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751554AbdDMVvU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 17:51:20 -0400
Content-Disposition: inline
In-Reply-To: <6fdcec91-829b-70c9-8780-992b67f6831a@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The DT binding is in tree and provides an example of how the switch
> looks like, below is the example, but I am also adding the MDIO bus and
> the PHYs just so you can see how things wind up:
> 
> switch_top@f0b00000 {
>         compatible = "simple-bus";
>         #size-cells = <1>;
>         #address-cells = <1>;
>         ranges = <0 0xf0b00000 0x40804>;
> 
>         ethernet_switch@0 {
>                 compatible = "brcm,bcm7445-switch-v4.0";
>                 #size-cells = <0>;
>                 #address-cells = <1>;
>                 reg = <0x0 0x40000
>                         0x40000 0x110
>                         0x40340 0x30
>                         0x40380 0x30
>                         0x40400 0x34
>                         0x40600 0x208>;
>                 reg-names = "core", "reg", intrl2_0", "intrl2_1",
>                             "fcb, "acb";
>                 interrupts = <0 0x18 0
>                                 0 0x19 0>;
>                 brcm,num-gphy = <1>;
>                 brcm,num-rgmii-ports = <2>;
>                 brcm,fcb-pause-override;
>                 brcm,acb-packets-inflight;
> 
>                 ports {
>                         #address-cells = <1>;
>                         #size-cells = <0>;
> 
>                         port@0 {
>                                 label = "gphy";
>                                 reg = <0>;
> 				phy-handle = <&phy5>;
>                         };
> 
> 			sw0port1: port@1 {
> 				label = "rgmii_1";
> 				reg = <1>;
> 				phy-mode = "rgmii";
> 				fixed-link {
> 					speed = <1000>;
> 					full-duplex;
> 				};
> 			}
>                 };
>         };
> 
> 	mdio@403c0 {
> 		reg = <0x403c0 0x8 0x40300 0x18>;
> 		#address-cells = <0x1>;
> 		#size-cells = <0x0>;
> 		compatible = "brcm,unimac-mdio";
> 		reg-names = "mdio", "mdio_indir_rw";
> 
> 		switch: switch@0 {
> 			broken-turn-around;
> 			reg = <0x0>;
> 			compatible = "brcm,bcm53125";
> 			#address-cells = <1>;
> 			#size-cells = <0>;
> 
> 			ports {
> 				..
> 				port@8 {
> 					ethernet = <&sw0port1>;
> 				};
> 				...
> 			};
> 		};
> 
> 		phy5: ethernet-phy@5 {
> 			reg = <0x5>;
> 			compatible = "ethernet-phy-ieee802.3-c22";
> 		};
> 	};
> };

So phy5 is connected to the internal switch with a phy-handle. But
because of your double usage of this node, it also can be mapped into
the external switches port 5?

Is that your problem?

It seems like you should add an mdio node inside your switch node, and
list your external switch internal/external phys there if needed.

   Andrew
