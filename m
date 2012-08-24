From: Tabi Timur-B04825 <B04825@freescale.com>
Subject: Re: [PATCH] [v2] netdev/phy: add MDIO bus multiplexer driven by a
 memory-mapped device
Date: Fri, 24 Aug 2012 00:28:10 +0000
Message-ID: <6AE080B68D46FC4BA2D2769E68D765B7059D1DC7@039-SN2MPN1-022.039d.mgd.msft.net>
References: <1345751071-23128-1-git-send-email-timur@freescale.com>
 <5036B4BD.70208@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Fleming Andy-AFLEMING <afleming@freescale.com>,
	David Miller <davem@davemloft.net>,
	"ddaney.cavm@gmail.com" <ddaney.cavm@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>
To: Stephen Warren <swarren@wwwdotorg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe001.messaging.microsoft.com ([213.199.154.204]:6766
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752155Ab2HXA2Y convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 20:28:24 -0400
In-Reply-To: <5036B4BD.70208@wwwdotorg.org>
Content-Language: en-US
Content-ID: <FE3D0CC80C53094A9E3CCA0E219E43EA@mgd.freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Warren wrote:
> On 08/23/2012 01:44 PM, Timur Tabi wrote:
>> Add support for an MDIO bus multiplexer controlled by a simple memory-mapped
>> device, like an FPGA.  The device must be memory-mapped and contain only
>> 8-bit registers (which keeps things simple).
>
>> +++ b/Documentation/devicetree/bindings/net/mdio-mux-mmioreg.txt
>
>> +	/* The FPGA node */
>> +	fpga: board-control@3,0 {
>> +		compatible = "fsl,p5020ds-fpga", "fsl,fpga-ngpixis";
>> +		reg = <3 0 0x30>;
>
> Why not add the following here:
>
> 	#address-cells = <1>:
> 	#size-cells = <1>;
> 	ranges = <...>;

I forgot to add them in the txt file.  They are in the real device tree.

>
>> +
>> +		mdio-mux-emi2 {
>> +			compatible = "mdio-mux-mmioreg", "mdio-mux";
>> +			mdio-parent-bus = <&xmdio0>;
>> +			#address-cells = <1>;
>> +			#size-cells = <0>;
>> +			reg = <9>; // BRDCFG1
>
> Then, that'd have to be <9 1>;

Actually, I had #size-cells = <0>.

>
> That way, ...
>
>> diff --git a/drivers/net/phy/mdio-mux-mmioreg.c b/drivers/net/phy/mdio-mux-mmioreg.c
>
>> +static int __devinit mdio_mux_mmioreg_probe(struct platform_device *pdev)
>
>> +	/* The MMIO device is the parent of this device */
>> +	np2 = of_get_parent(np);
>> +	if (!np2) {
>> +		dev_err(&pdev->dev, "could not find parent MMIO device\n");
>> +		return -ENODEV;
>> +	}
>> +
>> +	ret = of_address_to_resource(np2, 0, &res);
>> +	if (ret) {
>> +		dev_err(&pdev->dev, "could not obtain memory map for node %s\n",
>> +			np2->full_name);
>> +		return ret;
>> +	}
>> +	s->phys = res.start;
>
> You could simplify all that into just "of_iomap(np, 0)", and all the
> address translation etc. happens entirely automatically, in the standard
> fashion for DT.

Ah!  You're right.  I don't need to look for the parent node.  Duh.

-- 
Timur Tabi
Linux kernel developer at Freescale
