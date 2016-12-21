From: Ruslan Babayev <ruslan@babayev.com>
Subject: Re: [PATCH] phy: check if parent device is NULL
Date: Tue, 20 Dec 2016 18:35:53 -0800
Message-ID: <CAOpYhv9y_aD3CMcr+xkU56n+0RUYP4bxxorFiKDL_0WjvjvXbw@mail.gmail.com>
References: <87oa06upl5.fsf@babayev.com> <8cdfecf2-60c1-121d-a708-20de9f44d906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33613 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756411AbcLUCfz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 21:35:55 -0500
Received: by mail-io0-f196.google.com with SMTP id j76so66550ioe.0
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2016 18:35:54 -0800 (PST)
In-Reply-To: <8cdfecf2-60c1-121d-a708-20de9f44d906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, I saw that with the staging Octeon driver.
Your patch works for me too.

Thanks Florian!


On Tue, Dec 20, 2016 at 4:33 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 12/20/2016 03:51 PM, Ruslan Babayev wrote:
>> Fixes a crash observed on Octeon.
>>
>> Signed-off-by: Ruslan Babayev <ruslan@babayev.com>
>> Fixes: ec988ad78ed6 ("phy: Don't increment MDIO bus refcount unless it's a
>> different owner")
>
> Assuming you saw this with the staging Octeon driver, a fix has already
> been submitted:
>
> https://lkml.org/lkml/2016/12/14/756
>
> If this is with a different driver, I would rather we fix it in a
> similar way that the fix proposed above.
>
> Thanks
>
>> ---
>>  drivers/net/phy/phy_device.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
>> index 9c06f8028f0c..043328b85643 100644
>> --- a/drivers/net/phy/phy_device.c
>> +++ b/drivers/net/phy/phy_device.c
>> @@ -905,7 +905,8 @@ EXPORT_SYMBOL(phy_attached_print);
>>  int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>>                     u32 flags, phy_interface_t interface)
>>  {
>> -     struct module *ndev_owner = dev->dev.parent->driver->owner;
>> +     struct device *parent = dev->dev.parent;
>> +     struct module *ndev_owner = parent ? parent->driver->owner : NULL;
>>       struct mii_bus *bus = phydev->mdio.bus;
>>       struct device *d = &phydev->mdio.dev;
>>       int err;
>>
>
>
> --
> Florian
