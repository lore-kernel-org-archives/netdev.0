From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] net: fec: Add support for multiple phys on mdiobus
Date: Tue, 22 Jan 2013 16:26:10 +0100
Message-ID: <50FEAF92.1090604@grandegger.com>
References: <1358757475-21035-1-git-send-email-s.hauer@pengutronix.de> <50FD02B8.8080401@grandegger.com> <20130121100701.GX1906@pengutronix.de> <50FD2172.2020608@grandegger.com> <20130121120602.GZ1906@pengutronix.de> <50FE3E37.4010004@grandegger.com> <50FEA691.4050904@openwrt.org> <50FEAA28.1070003@grandegger.com> <50FEAE12.7090307@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sascha Hauer <s.hauer@pengutronix.de>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, shawn.guo@linaro.org,
	davem@davemloft.net
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ngcobalt02.manitu.net ([217.11.48.102]:40797 "EHLO
	ngcobalt02.manitu.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753227Ab3AVP0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 10:26:19 -0500
In-Reply-To: <50FEAE12.7090307@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/2013 04:19 PM, Florian Fainelli wrote:
> On 01/22/2013 04:03 PM, Wolfgang Grandegger wrote:
>> On 01/22/2013 03:47 PM, Florian Fainelli wrote:
>>> On 01/22/2013 08:22 AM, Wolfgang Grandegger wrote:
>>>>> Well this could be done when the fixed phy driver could be registered
>>>>> with the devicetree, maybe like this:
>>>>>
>>>>>      fixed-phy: mdiophy {
>>>>>          compatible = "mdio-fixed-phy";
>>>>>          link = "100FD";
>>>>>      };
>>>> I find that confusing. There is *no* phy but just a fixed link to the
>>>> switch...
>>>>
>>>>> The good thing about this would be that every ethernet driver could
>>>>> just
>>>>> use such a fixed phy, any external mdio phy (like on Marvell
>>>>> Armada) or
>>>>> just a phy connected to the internal mdio interface provided by the
>>>>> ethernet
>>>>> core.
>>>> What is wrong with the existing "fixed-link" property of the *ethernet*
>>>> node. The fixed-link handling should/could be done in the phy layer,
>>>> and
>>>> not in the driver as it currently is implemented. Maybe that's the
>>>> reason why the current code is regarded as hack!
>>> As far as I have used it with the CPMAC driver, the fixed PHY is a
>>> specific PHY device and there is no specific handling to be done by the
>>> Ethernet MAC driver but eventually changing its MII bus id so that it is
>>> named "fixed-0" to allow the fixed PHY driver to bind. Put differently,
>> There is special handling for the fixed link, e.g. here:
>>
>> http://lxr.linux.no/#linux+v3.7.4/drivers/net/ethernet/freescale/gianfar.c#L1462
>>
>>
>> This could be hidden in the PHY layer allowing all ethernet drivers
>> using the "fixed-link" property.
> 
> Ok, so in the end you could have potentially an ethernet PHY node
> containing the following properties:
> - fixed-link
> - fixed-speed
> - fixed-duplex
> 
> and treat it as a fixed-phy. If so, this would be pretty handy.

The "fixed-link" property already allows to specify speed, duplex, etc.:

http://lxr.linux.no/#linux+v3.7.4/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt#L48

Wolfgang.
