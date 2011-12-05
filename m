From: Heiko Schocher <hs@denx.de>
Subject: Re: [PATCH] net, fixed phy: make BUSID configurable
Date: Mon, 05 Dec 2011 11:21:09 +0100
Message-ID: <4EDC9B15.8020302@denx.de>
References: <1322991444-20626-1-git-send-email-hs@denx.de>
 <20111204.132321.9566486322084069.davem@davemloft.net>
Reply-To: hs@denx.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, vbordug@ru.mvista.com, akpm@osdl.org,
	jeff@garzik.org, wd@denx.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.relay.invitel.net ([62.77.203.3]:38814 "EHLO
	a.relay.invitel.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753783Ab1LEK2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 05:28:04 -0500
In-reply-to: <20111204.132321.9566486322084069.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

David Miller wrote:
> From: Heiko Schocher <hs@denx.de>
> Date: Sun,  4 Dec 2011 10:37:24 +0100
> 
>> Signed-off-by: Heiko Schocher <hs@denx.de>
> 
> Give me a break.
> 
> You can't submit a change like this with essentially an
> empty commit message.

Uh, yes, sorry!

> Why in the world does this ever need to be configurable?
> Are there alternative (and much better) ways to deal with
> whatever problem this patch solves?
> 
> You've presented no information about why you need to make this
> change, and more importantly why no viable alternatives exist
> to solve your problem.

On a am1808 based board porting to current kernel, I have connected
a KSZ8864RMN switch and using the drivers/net/ethernet/ti/davinci_emac.c
driver. To the switch I have always 100/FULL connection and so
I decided to use the fixed PHY driver. But the busid 0 is used
from the drivers/net/ethernet/ti/davinci_emac.c driver, and the
fixed PHY driver is fix at busid 0 ...

Looking in the drivers/net/ethernet/ti/davinci_emac.c in emac_dev_open()
there is the possibility if no priv->phy_id is defined through
plattform code, to use a fixed 100/FULL speed and duplex settings ...
which would fix my needs ...

But code did not reach this, because first a:

        if (!priv->phy_id) {
                struct device *phy;

                phy = bus_find_device(&mdio_bus_type, NULL, NULL,
                                      match_first_device);
                if (phy)
                        priv->phy_id = dev_name(phy);
        }

is checked ... maybe it is better to fix this here by removing this
"if (!priv->phy_id) {" and do not use the fixed PHY driver?

bye,
Heiko
-- 
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
