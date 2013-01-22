From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] net: fec: Add support for multiple phys on mdiobus
Date: Tue, 22 Jan 2013 15:47:45 +0100
Message-ID: <50FEA691.4050904@openwrt.org>
References: <1358757475-21035-1-git-send-email-s.hauer@pengutronix.de> <50FD02B8.8080401@grandegger.com> <20130121100701.GX1906@pengutronix.de> <50FD2172.2020608@grandegger.com> <20130121120602.GZ1906@pengutronix.de> <50FE3E37.4010004@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sascha Hauer <s.hauer@pengutronix.de>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, shawn.guo@linaro.org,
	davem@davemloft.net
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:34157 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608Ab3AVOua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 09:50:30 -0500
Received: by mail-lb0-f173.google.com with SMTP id gf7so4502182lbb.32
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 06:50:28 -0800 (PST)
In-Reply-To: <50FE3E37.4010004@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/2013 08:22 AM, Wolfgang Grandegger wrote:
>> Well this could be done when the fixed phy driver could be registered
>> with the devicetree, maybe like this:
>>
>> 	fixed-phy: mdiophy {
>> 		compatible = "mdio-fixed-phy";
>> 		link = "100FD";
>> 	};
>
> I find that confusing. There is *no* phy but just a fixed link to the
> switch...
>
>> The good thing about this would be that every ethernet driver could just
>> use such a fixed phy, any external mdio phy (like on Marvell Armada) or
>> just a phy connected to the internal mdio interface provided by the ethernet
>> core.
>
> What is wrong with the existing "fixed-link" property of the *ethernet*
> node. The fixed-link handling should/could be done in the phy layer, and
> not in the driver as it currently is implemented. Maybe that's the
> reason why the current code is regarded as hack!

As far as I have used it with the CPMAC driver, the fixed PHY is a 
specific PHY device and there is no specific handling to be done by the 
Ethernet MAC driver but eventually changing its MII bus id so that it is 
named "fixed-0" to allow the fixed PHY driver to bind. Put differently, 
using the fixed PHY driver is a kind of "last" resort thing to cope with 
situations like:

- switch not providing a consistent PHY-like interface on the MDC/MDIO bus
- switches not connected to the MDC/MDIO bus of the Ethernet MAC they 
forward to

What exactly do you mean by "as it currently is implemented"? that you 
do not like?
--
Florian
