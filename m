From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH] [v2] netdev/phy: add MDIO bus multiplexer driven by a
 memory-mapped device
Date: Fri, 24 Aug 2012 14:18:02 -0500
Message-ID: <5037D36A.50705@freescale.com>
References: <5037C815.4020906@wwwdotorg.org> <5037C9AF.3060903@freescale.com> <5037CE45.4010309@wwwdotorg.org> <20120824.150740.9047511945034908.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <swarren@wwwdotorg.org>, <timur@freescale.com>,
	<afleming@freescale.com>, <ddaney.cavm@gmail.com>,
	<netdev@vger.kernel.org>, <devicetree-discuss@lists.ozlabs.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe004.messaging.microsoft.com ([216.32.181.184]:6037
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755114Ab2HXTSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 15:18:12 -0400
In-Reply-To: <20120824.150740.9047511945034908.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2012 02:07 PM, David Miller wrote:
> From: Stephen Warren <swarren@wwwdotorg.org>
> Date: Fri, 24 Aug 2012 12:56:05 -0600
> 
>> In the I2C case, the address spaces are disjoint, so there's never any
>> mapping between them, so there's no need for ranges.
>>
>> Any time the child address space is intended to be part of the parent's
>> address space, I believe ranges is supposed to be specified, perhaps
>> even mandatory, even if the translation is 1:1.

Yes, it's mandatory (even if the kernel lets you get away without it for
the sake of some broken Apple firmware, IIRC).  If the translation is an
identity map you can use an empty "ranges;".

> Regardless, you really can't just generically translate ranges
> in some universal way and expect it to work in all cases.
> 
> You need bus specific drivers to deal with various special
> cases.
> 
> See the *_map() methods implemented in:
> 
> 	arch/sparc/kernel/of_device_64.c
> 
> for example.

We don't expect it to work in all cases.  We expect it to work if the
bus node is on the whitelist for which we create devices on
platform_bus, there's a platform driver that binds against it, and that
driver calls of_iomap() or equivalent because the binding says that reg
refers to something that is memory mapped.

-Scott
