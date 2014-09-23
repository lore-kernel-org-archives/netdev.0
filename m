From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH v4 3/9] Documentation: bindings: net: add the Marvell PXA168 Ethernet controller
Date: Tue, 23 Sep 2014 18:29:48 +0200
Message-ID: <9401592.hUYDkriFVO@wuerfel>
References: <1411474536-22626-1-git-send-email-antoine.tenart@free-electrons.com> <4014272.rJbSfrLcuB@wuerfel> <542195B0.6080706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, zmxu-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Antoine Tenart <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	jszhang-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <542195B0.6080706-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 23 September 2014 17:45:52 Sebastian Hesselbarth wrote:
> For reference, this is what we have for MVEBU SoCs with multiple ports
> per controller:
> 
> eth: ethernet-ctrl@72000 {
>         compatible = "marvell,orion-eth";
>         #address-cells = <1>;
>         #size-cells = <0>;
>         reg = <0x72000 0x4000>;
>         clocks = <&gate_clk 2>;
>         marvell,tx-checksum-limit = <1600>;
>         status = "disabled";
> 
>         ethernet-port@0 {
>                 compatible = "marvell,orion-eth-port";
>                 reg = <0>;
>                 interrupts = <29>;
>                 /* overwrite MAC address in bootloader */
>                 local-mac-address = [00 00 00 00 00 00];
>                 phy-handle = <&ethphy>;
>         };
> };
> 
> mdio: mdio-bus@72004 {
>         compatible = "marvell,orion-mdio";
>         #address-cells = <1>;
>         #size-cells = <0>;
>         reg = <0x72004 0x84>;
>         interrupts = <30>;
>         clocks = <&gate_clk 2>;
>         status = "disabled";
>         ethphy: ethernet-phy {
>                 /* set phy address in board file */
>         };
> };
> 

But in this example, you have the same registers and the same
clocks in two nodes, which are even used by the same device driver
at the moment. It's not a big issue, but my feeling is that Antoine's
approach was actually better because it more closely reflects
the way that the hardware is built.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
