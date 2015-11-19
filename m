From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] phylib: Make PHYs children of their MDIO bus, not the
 bus' parent.
Date: Fri, 20 Nov 2015 00:33:08 +0300
Message-ID: <564E4014.3010702@cogentembedded.com>
References: <1440198963-20080-1-git-send-email-ddaney.cavm@gmail.com>
 <564E3659.1040709@cogentembedded.com> <20151119210651.GA5044@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Daney <ddaney.cavm@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	David Daney <david.daney@cavium.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Grant Likely <grant.likely@secretlab.ca>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:36080 "EHLO
	mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758984AbbKSVdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 16:33:14 -0500
Received: by lfs39 with SMTP id 39so57066223lfs.3
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 13:33:13 -0800 (PST)
In-Reply-To: <20151119210651.GA5044@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/20/2015 12:06 AM, Andrew Lunn wrote:

>>> From: David Daney <david.daney@cavium.com>
>>>
>>> commit 18ee49ddb0d2 ("phylib: rename mii_bus::dev to mii_bus::parent")
>>> changed the parent of PHY devices from the bus to the bus parent.
>>>
>>> Then, commit 4dea547fef1b ("phylib: rework to prepare for OF
>>> registration of PHYs") moved the code into phy_device.c
>>>
>>> At this point, it is somewhat unclear why the change was seen as
>>> necessary.  But, when we look at the device model tree in
>>> /sys/devices, it is clearly incorrect.  The PHYs should be children of
>>> their MDIO bus.
>>>
>>> Change the PHY's parent device to be the MDIO bus device.
>>>
>>> Cc: Lennert Buytenhek <buytenh@wantstofly.org>
>>> Cc: Grant Likely <grant.likely@secretlab.ca>
>>> Signed-off-by: David Daney <david.daney@cavium.com>
>>> ---
>>>   drivers/net/phy/phy_device.c | 2 +-
>>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
>>> index 0302483..55f0178 100644
>>> --- a/drivers/net/phy/phy_device.c
>>> +++ b/drivers/net/phy/phy_device.c
>>> @@ -176,7 +176,7 @@ struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
>>>   	if (c45_ids)
>>>   		dev->c45_ids = *c45_ids;
>>>   	dev->bus = bus;
>>> -	dev->dev.parent = bus->parent;
>>> +	dev->dev.parent = &bus->dev;
>>>   	dev->dev.bus = &mdio_bus_type;
>>>   	dev->irq = bus->irq != NULL ? bus->irq[addr] : PHY_POLL;
>>>   	dev_set_name(&dev->dev, PHY_ID_FMT, bus->id, addr);
>>
>>     This patch makes my sh_eth driver fail to connect to PHY usinjg
>> of_phy_connect(). (The ravb driver fails too but for some other
>> reason.)
>
> Hi Sergei
>
> What phy is it?

    Micrel KSZ8041RNLI for sh_eth, KSZ9031 for ravb.

> Do you have phy DT properties in the MAC node?

    I have PHY subnodes (with props) in the MAC node.

>     Andrew

MBR, Sergei
