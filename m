From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] net: fec: Add support for multiple phys on mdiobus
Date: Tue, 22 Jan 2013 08:22:31 +0100
Message-ID: <50FE3E37.4010004@grandegger.com>
References: <1358757475-21035-1-git-send-email-s.hauer@pengutronix.de> <50FD02B8.8080401@grandegger.com> <20130121100701.GX1906@pengutronix.de> <50FD2172.2020608@grandegger.com> <20130121120602.GZ1906@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	shawn.guo@linaro.org, davem@davemloft.net
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ngcobalt02.manitu.net ([217.11.48.102]:54116 "EHLO
	ngcobalt02.manitu.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889Ab3AVHWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 02:22:40 -0500
In-Reply-To: <20130121120602.GZ1906@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/21/2013 01:06 PM, Sascha Hauer wrote:
> On Mon, Jan 21, 2013 at 12:07:30PM +0100, Wolfgang Grandegger wrote:
>> On 01/21/2013 11:07 AM, Sascha Hauer wrote:
>>> On Mon, Jan 21, 2013 at 09:56:24AM +0100, Wolfgang Grandegger wrote:
>>>> On 01/21/2013 09:37 AM, Sascha Hauer wrote:
>>>>> There may be multiple phys on an mdio bus. This series adds support
>>>>> for this to the fec driver. I recently had a board which has a switch
>>>>> connected to the fec's mdio bus, so I had to pick the correct phy.
>>>>
>>>> Pick one PHY from a switch port? Well, does a PHY-less (or fixed-link)
>>>> configuration for a switch not make more sense?
>>>
>>> Yes, you're probably right.
>>>
>>>> Various ARM Ethernet
>>>> contoller drivers do not support it. I recently needed a hack for an
>>>> AT91 board.
>>>
>>> I wonder how we want to proceed. Should there be a devicetree property
>>> 'fixed-link' like done for fs_enet (and not recommended for new code,
>>> stated in the comment above of_phy_connect_fixed_link)?
>>
>> Also the gianfar and ucc_geth drivers use this interface (via fixed
>> link phy). I tried to use it for the AT91 macb driver but stopped
>> quickly because the usage was not straight forward (too much code)...
>> even if the idea of using a fake fixed-link phy is not bad.
>>
>>> Currently I have a property 'phy' in the fec binding which has a phandle
>>> to a phy provided by the fec's mdio bus, but this could equally well
>>
>> But than the cable must be connected to the associated switch port.
>>
>>> point to a fixed dummy phy:
>>>
>>> 	phy = &fixed-phy;
>>
>> The link speed, full/half duplex and maybe some mroe parameter should
>> be configurable via device tree.
> 
> Well this could be done when the fixed phy driver could be registered
> with the devicetree, maybe like this:
> 
> 	fixed-phy: mdiophy {
> 		compatible = "mdio-fixed-phy";
> 		link = "100FD";
> 	};

I find that confusing. There is *no* phy but just a fixed link to the
switch...

> The good thing about this would be that every ethernet driver could just
> use such a fixed phy, any external mdio phy (like on Marvell Armada) or
> just a phy connected to the internal mdio interface provided by the ethernet
> core.

What is wrong with the existing "fixed-link" property of the *ethernet*
node. The fixed-link handling should/could be done in the phy layer, and
not in the driver as it currently is implemented. Maybe that's the
reason why the current code is regarded as hack!

> I probably should write a RFC to devicetree-discuss.

Yep,

Wolfgang.
