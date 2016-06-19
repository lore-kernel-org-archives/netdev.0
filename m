From: Oliver Graute <oliver.graute@gmail.com>
Subject: Re: Micrel Phy KSZ8031 clock select setting in dts
Date: Sun, 19 Jun 2016 21:29:41 +0200
Message-ID: <5766f2a8.8f1d1c0a.10cf8.1751@mx.google.com>
References: <20160617130438.GB6604@graute-opti>
 <bda2a612-37fd-9b73-5aad-6bc62ac2f520@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, johan@kernel.org,
	bth@kamstrup.dk, s.hauer@pengutronix.de
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:38648 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375AbcFST3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 15:29:46 -0400
Received: by mail-wm0-f49.google.com with SMTP id r201so34949755wme.1
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2016 12:29:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <bda2a612-37fd-9b73-5aad-6bc62ac2f520@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/06/16, Sergei Shtylyov wrote:
> On 06/17/2016 04:04 PM, Oliver Graute wrote:
> 
> >I try to enable a Micrel KSZ8031 in my imx6ul board device tree. But i'am
> >struggeling with the setting for KSZPHY_RMII_REF_CLK_SEL BIT(7). In my
> >revision of this Micrel KSZ8031 Phy the Bit(7) has to be true. The 0x1f
> >register must be 0x8180.
> >
> >How can I configure this register setting into my DTS?
> >
> >I already checked Documentation/devicetree/bindings/net/micrel.txt
> >
> >but i'am not sure if this still up to date. There where some reworks
> >after git commit 86dc1342
> >
> >some other commits related to this Phy clock setting I checked
> >
> >commit 1fadee0c3
> >commit b838b4aced
> >
> >my non working device tree blob for the phy is:
> >
> >&fec1 {
> >	pinctrl-names = "default";
> >	pinctrl-0 = <&pinctrl_enet1>;
> >	phy-mode = "rmii";
> >	rmmi-ref-clk-sel = <1>;
> >	phy-handle = <&ethphy0>;
> >	status = "okay";
> >
> >	mdio {
> >		#address-cells = <1>;
> >		#size-cells = <0>;
> >
> >		ethphy0: ethernet-phy@0 {
> >			compatible = "micrel,ksz8031";
> >			reg = <0>;
> >		};
> >	};
> >};
> >
> >
> >some clue how to configure this phy register setting correctly?
> 
>    Tried specifying "micrel,rmii-reference-clock-select-25-mhz"
> property in the PHY node?
> 

No, I expect my RMII reference clock on 50 MHz. So I thought that
rmii-reference-clock-select-25-mhz isn't the right setting for me here.

If I manually set bit 7 in the 0x1f register to true The Phy only works
until the next ifconfig eth0 up/down cycle. After the Phy Reset Bit 7 is
false again and Phy isn't working anymore.


Best Regards,

Oliver
