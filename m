From: Stephen Warren <swarren@wwwdotorg.org>
Subject: Re: [PATCH] [v2] netdev/phy: add MDIO bus multiplexer driven by a
 memory-mapped device
Date: Fri, 24 Aug 2012 12:56:05 -0600
Message-ID: <5037CE45.4010309@wwwdotorg.org>
References: <1345751071-23128-1-git-send-email-timur@freescale.com> <5036B4BD.70208@wwwdotorg.org> <6AE080B68D46FC4BA2D2769E68D765B7059D1DC7@039-SN2MPN1-022.039d.mgd.msft.net> <5036EB06.7060807@wwwdotorg.org> <5037AB67.6030106@freescale.com> <5037C815.4020906@wwwdotorg.org> <5037C9AF.3060903@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Fleming Andy-AFLEMING <afleming@freescale.com>,
	David Miller <davem@davemloft.net>,
	"ddaney.cavm@gmail.com" <ddaney.cavm@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	Scott Wood <scottwood@freescale.com>
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avon.wwwdotorg.org ([70.85.31.133]:33479 "EHLO
	avon.wwwdotorg.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753605Ab2HXS4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 14:56:09 -0400
In-Reply-To: <5037C9AF.3060903@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2012 12:36 PM, Timur Tabi wrote:
> Stephen Warren wrote:
>> When translating the child node's reg property into the parent's address
>> space, the parent's reg property shouldn't even be used at all; all the
>> mapping is done through the ranges property.
>>
>> I thought the code error-checked for a missing ranges property, but I
>> guess not...
> 
> I don't think 'ranges' is always necessary, because sometimes the child
> nodes have a different address space that's not mapped to the parent.  For
> instance, I2C devices have addresses that are not mapped to the I2C
> controller itself.

In the I2C case, the address spaces are disjoint, so there's never any
mapping between them, so there's no need for ranges.

Any time the child address space is intended to be part of the parent's
address space, I believe ranges is supposed to be specified, perhaps
even mandatory, even if the translation is 1:1.

> Anyway, thanks to Scott for helping me figure this out.  I was missing a
> ranges property:
> 
> 	fpga: board-control@3,0 {
> 		#address-cells = <1>;
> 		#size-cells = <1>;
> 		compatible = "fsl,p5020ds-fpga", "fsl,fpga-ngpixis";
> 		reg = <3 0 0x30>;
> 		ranges = <0 3 0 0x30>;
> 
> This maps the child address of 0 to the parent address of 3 0.

Yes, that looks reasonable.
