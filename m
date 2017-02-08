From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Kernel crashes in phy_attach_direct()
Date: Wed, 8 Feb 2017 08:39:53 -0800
Message-ID: <c71ed92e-b4de-2fbc-28c8-7afbc474049f@gmail.com>
References: <CAOMZO5C58--W1q+i26-+DBcton0Bk_o3zVfyuumM+Y=OemQ_Aw@mail.gmail.com>
 <20170208142857.GD10855@lunn.ch>
 <CAOMZO5BzLh4az9t=fJkG80GW3_xdD3YxUbagL4dJp7Hwr4koZw@mail.gmail.com>
 <20170208144029.GE10855@lunn.ch>
 <CAOMZO5CjRbvPJjNDGkOFjz+AZ1ydN9+SRBsypCPyNocPoFOdRA@mail.gmail.com>
 <20170208145148.GF10855@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>
To: Andrew Lunn <andrew@lunn.ch>, Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f170.google.com ([74.125.82.170]:35510 "EHLO
        mail-ot0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752531AbdBHQr7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 11:47:59 -0500
Received: by mail-ot0-f170.google.com with SMTP id 65so117156051otq.2
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 08:47:59 -0800 (PST)
In-Reply-To: <20170208145148.GF10855@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/08/2017 06:51 AM, Andrew Lunn wrote:
>> Yes, this is what I am using right now:
>>
>> --- a/drivers/net/phy/phy_device.c
>> +++ b/drivers/net/phy/phy_device.c
>> @@ -920,11 +920,6 @@ int phy_attach_direct(struct net_device *dev,
>> struct phy_device *phydev,
>>                 return -EIO;
>>         }
>>
>> -       if (!try_module_get(d->driver->owner)) {
>> -               dev_err(&dev->dev, "failed to get the device driver module\n");
>> -               return -EIO;
>> -       }
>> -
>>         get_device(d);
>>
>>         /* Assume that if there is no driver, that it doesn't
>> @@ -946,6 +941,11 @@ int phy_attach_direct(struct net_device *dev,
>> struct phy_device *phydev,
>>                         goto error;
>>         }
>>
>> +       if (!try_module_get(d->driver->owner)) {
>> +               dev_err(&dev->dev, "failed to get the device driver module\n");
>> +               return -EIO;
>> +       }
>> +
>>         if (phydev->attached_dev) {
>>                 dev_err(&dev->dev, "PHY already attached\n");
>>                 err = -EBUSY;
>>
>> Would you like me to submit this one?
> 
> I'm just wondering about the get_device(d); Does the ordering matter
> here? Lets wait for Florian before submitting a patch.

I sent a fix for that last night:

https://patchwork.ozlabs.org/patch/725522/

Sorry about that!
-- 
Florian
