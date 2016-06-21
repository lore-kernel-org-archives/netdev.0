From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: Micrel Phy KSZ8031 clock select setting in dts
Date: Tue, 21 Jun 2016 08:16:03 +0200
Message-ID: <20160621061603.GV9677@pengutronix.de>
References: <20160617130438.GB6604@graute-opti>
 <bda2a612-37fd-9b73-5aad-6bc62ac2f520@cogentembedded.com>
 <5766f2a8.8f1d1c0a.10cf8.1751@mx.google.com>
 <20160620062101.GL9677@pengutronix.de>
 <20160620120821.GA19639@graute-opti>
 <20160620124539.GB20362@lunn.ch>
 <20160620171406.GA4455@graute-opti>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Andrew Lunn <andrew@lunn.ch>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, f.fainelli@gmail.com, johan@kernel.org,
	bth@kamstrup.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:55988 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751961AbcFUHdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 03:33:16 -0400
Content-Disposition: inline
In-Reply-To: <20160620171406.GA4455@graute-opti>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 20, 2016 at 07:14:06PM +0200, Oliver Graute wrote:
> On 20/06/16, Andrew Lunn wrote:
> > > &fec1 {
> > > 	pinctrl-names = "default";
> > > 	pinctrl-0 = <&pinctrl_enet1>;
> > > 	phy-mode = "rmii";
> > > 	micrel,rmii-reference-clock-select-25-mhz;
> > > 	clocks,rmii-ref;
> > 
> > You are adding phy properties, not MAC properties. Please put them in
> > the phy node.
> 
> yes, you are right. I fixed this and added the clock like sascha and
> sergei proposed. (thx to you all)
> 
> my dts node now looks like this:
> 
> &fec1 {
> 	pinctrl-names = "default";
> 	pinctrl-0 = <&pinctrl_enet1>;
> 	phy-mode = "rmii";
> 	status = "okay";
> 
> 	mdio {
> 		#address-cells = <1>;
> 		#size-cells = <0>;
> 
> 		ethphy0: ethernet-phy@0 {
> 			compatible = "micrel,ksz8031";
> 			micrel,rmii-reference-clock-select-25-mhz;
> 			clocks = <&mdc>;
> 			clock-names = "rmii-ref";
> 			phy-handle = <&ethphy0>;
> 			reg = <0>;
> 		};
> 
> 	};
> 
> 	mdc: rmii-ref {
> 		#clock-cells = <0>;
> 		compatible ="fixed-clock";
> 		clock-frequency = <50000000>;
> 	};
> };

To make that clear: Which phy do you have: KSZ8031RNL or KSZ8031RNLI?
The former has 25MHz default input clock whereas the latter has 50MHz
default input clock.

I assume you have the KSZ8031RNL and use it with 50MHz (so the non
default case), hence you have to set the KSZPHY_RMII_REF_CLK_SEL bit.
The "micrel,rmii-reference-clock-select-25-mhz" means "Setting the bit
selects 25MHz" which is not the case here, so you have to remove the
property.
Could it be that your initial setting just did not work because of other
mistakes, like no correct clock?

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
