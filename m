From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: Micrel Phy KSZ8031 clock select setting in dts
Date: Mon, 20 Jun 2016 08:21:01 +0200
Message-ID: <20160620062101.GL9677@pengutronix.de>
References: <20160617130438.GB6604@graute-opti>
 <bda2a612-37fd-9b73-5aad-6bc62ac2f520@cogentembedded.com>
 <5766f2a8.8f1d1c0a.10cf8.1751@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, f.fainelli@gmail.com, johan@kernel.org,
	bth@kamstrup.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:58125 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751665AbcFTGVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 02:21:06 -0400
Content-Disposition: inline
In-Reply-To: <5766f2a8.8f1d1c0a.10cf8.1751@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 19, 2016 at 09:29:41PM +0200, Oliver Graute wrote:
> On 17/06/16, Sergei Shtylyov wrote:
> > On 06/17/2016 04:04 PM, Oliver Graute wrote:
> > 
> > >I try to enable a Micrel KSZ8031 in my imx6ul board device tree. But i'am
> > >struggeling with the setting for KSZPHY_RMII_REF_CLK_SEL BIT(7). In my
> > >revision of this Micrel KSZ8031 Phy the Bit(7) has to be true. The 0x1f
> > >register must be 0x8180.
> > >
> > >How can I configure this register setting into my DTS?
> > >
> > >I already checked Documentation/devicetree/bindings/net/micrel.txt
> > >
> > >but i'am not sure if this still up to date. There where some reworks
> > >after git commit 86dc1342
> > >
> > >some other commits related to this Phy clock setting I checked
> > >
> > >commit 1fadee0c3
> > >commit b838b4aced
> > >
> > >my non working device tree blob for the phy is:
> > >
> > >&fec1 {
> > >	pinctrl-names = "default";
> > >	pinctrl-0 = <&pinctrl_enet1>;
> > >	phy-mode = "rmii";
> > >	rmmi-ref-clk-sel = <1>;
> > >	phy-handle = <&ethphy0>;
> > >	status = "okay";
> > >
> > >	mdio {
> > >		#address-cells = <1>;
> > >		#size-cells = <0>;
> > >
> > >		ethphy0: ethernet-phy@0 {
> > >			compatible = "micrel,ksz8031";
> > >			reg = <0>;
> > >		};
> > >	};
> > >};
> > >
> > >
> > >some clue how to configure this phy register setting correctly?
> > 
> >    Tried specifying "micrel,rmii-reference-clock-select-25-mhz"
> > property in the PHY node?
> > 
> 
> No, I expect my RMII reference clock on 50 MHz. So I thought that
> rmii-reference-clock-select-25-mhz isn't the right setting for me here.

You misunderstand the meaning of this property. It is not for specifying
25MHz. Instead, it's for specifying the polarity of the
KSZPHY_RMII_REF_CLK_SEL bit.
Background is that the Micrel Phys come with different default input
frequencies. Unfortunately Micrel did not change the default value of
this bit for the different variants, instead they kept the default value
the same and inverted the meaning for the different variants.
Sergei is right, you have to set
micrel,rmii-reference-clock-select-25-mhz.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
