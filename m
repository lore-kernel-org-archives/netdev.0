From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net v2 1/3] net: phy: Fix PHY module checks
Date: Wed, 8 Feb 2017 09:46:27 -0800
Message-ID: <34e621b5-9fb7-aad5-126f-291b52af30be@gmail.com>
References: <20170208073746.10963-1-f.fainelli@gmail.com>
 <20170208073746.10963-2-f.fainelli@gmail.com>
 <F95AC9340317A84688A5F0DF0246F3F201ED9E4E@szxemi502-mbx.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "rmk+kernel@armlinux.org.uk" <rmk+kernel@armlinux.org.uk>
To: maowenan <maowenan@huawei.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:33081 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754150AbdBHR4A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 12:56:00 -0500
Received: by mail-qt0-f193.google.com with SMTP id n13so24319658qtc.0
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 09:55:59 -0800 (PST)
In-Reply-To: <F95AC9340317A84688A5F0DF0246F3F201ED9E4E@szxemi502-mbx.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/07/2017 11:57 PM, maowenan wrote:
> 
> 
>> -----Original Message-----
>> From: Florian Fainelli [mailto:f.fainelli@gmail.com]
>> Sent: Wednesday, February 08, 2017 3:38 PM
>> To: netdev@vger.kernel.org
>> Cc: davem@davemloft.net; andrew@lunn.ch; rmk+kernel@armlinux.org.uk;
>> maowenan; Florian Fainelli
>> Subject: [PATCH net v2 1/3] net: phy: Fix PHY module checks
>>
>> The Generic PHY drivers gets assigned after we checked that the current PHY
>> driver is NULL, so we need to check a few things before we can safely
>> derference d->driver. Update phy_attach_direct() and phy_detach() accordingly
>> to be resilient to these cases.
>>
>> Even though the Generic PHY driver defaults to phy_probe() which can hardly
>> fail at the moment, let's fix the label so we don't call phy_detach() on a network
>> device we have not attached yet.
>>
>> Fixes: cafe8df8b9bc ("net: phy: Fix lack of reference count on PHY driver")
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>  drivers/net/phy/phy_device.c | 8 +++++---
>>  1 file changed, 5 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c index
>> 0d8f4d3847f6..bde240bf8d7b 100644
>> --- a/drivers/net/phy/phy_device.c
>> +++ b/drivers/net/phy/phy_device.c
>> @@ -920,7 +920,7 @@ int phy_attach_direct(struct net_device *dev, struct
>> phy_device *phydev,
>>  		return -EIO;
>>  	}
>>
>> -	if (!try_module_get(d->driver->owner)) {
>> +	if (d->driver && !try_module_get(d->driver->owner)) {
>>  		dev_err(&dev->dev, "failed to get the device driver module\n");
>>  		return -EIO;
> 
> Hi Florian,
>   Here "return -EIO" will miss decreasing bus->owner reference count.

Good catch thanks!

-- 
Florian
