From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH] [v2] netdev/phy: add MDIO bus multiplexer driven by a
 memory-mapped device
Date: Fri, 24 Aug 2012 13:36:31 -0500
Message-ID: <5037C9AF.3060903@freescale.com>
References: <1345751071-23128-1-git-send-email-timur@freescale.com> <5036B4BD.70208@wwwdotorg.org> <6AE080B68D46FC4BA2D2769E68D765B7059D1DC7@039-SN2MPN1-022.039d.mgd.msft.net> <5036EB06.7060807@wwwdotorg.org> <5037AB67.6030106@freescale.com> <5037C815.4020906@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Fleming Andy-AFLEMING <afleming@freescale.com>,
	David Miller <davem@davemloft.net>,
	"ddaney.cavm@gmail.com" <ddaney.cavm@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	Scott Wood <scottwood@freescale.com>
To: Stephen Warren <swarren@wwwdotorg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe002.messaging.microsoft.com ([213.199.154.205]:37099
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751775Ab2HXSgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 14:36:42 -0400
In-Reply-To: <5037C815.4020906@wwwdotorg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Warren wrote:
> When translating the child node's reg property into the parent's address
> space, the parent's reg property shouldn't even be used at all; all the
> mapping is done through the ranges property.
> 
> I thought the code error-checked for a missing ranges property, but I
> guess not...

I don't think 'ranges' is always necessary, because sometimes the child
nodes have a different address space that's not mapped to the parent.  For
instance, I2C devices have addresses that are not mapped to the I2C
controller itself.

Anyway, thanks to Scott for helping me figure this out.  I was missing a
ranges property:

	fpga: board-control@3,0 {
		#address-cells = <1>;
		#size-cells = <1>;
		compatible = "fsl,p5020ds-fpga", "fsl,fpga-ngpixis";
		reg = <3 0 0x30>;
		ranges = <0 3 0 0x30>;

This maps the child address of 0 to the parent address of 3 0.  It seems
obvious now, but it was driving me crazy.  We've never put child devices
under our FPGA nodes, so there was no prior use case of a 'ranges'
property in any of the localbus devices that I could learn from.  Plus,
this is the first time we're probing directly on a child of a localbus device.

-- 
Timur Tabi
Linux kernel developer at Freescale
