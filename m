From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [net, v3, 1/3] net: phy: Fix PHY module checks and NULL deref in
 phy_attach_direct()
Date: Wed, 8 Feb 2017 23:13:51 -0800
Message-ID: <8c63b88f-c7d3-dd53-e3a8-9d38bb5a154c@gmail.com>
References: <20170209001401.2564-2-f.fainelli@gmail.com>
 <589C1309.5040302@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maowenan <maowenan@huawei.com>,
        andrew@lunn.ch, rmk+kernel@armlinux.org.uk, festevam@gmail.com,
        davem@davemloft.net, nikita.yoush@cogentembedded.com
To: hs@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f196.google.com ([74.125.82.196]:34153 "EHLO
        mail-ot0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751918AbdBIHOG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 02:14:06 -0500
Received: by mail-ot0-f196.google.com with SMTP id 73so913563otj.1
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 23:13:55 -0800 (PST)
In-Reply-To: <589C1309.5040302@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/08/2017 10:58 PM, Heiko Schocher wrote:
> Hello Florian,
> 
> Am 09.02.2017 um 01:13 schrieb Florian Fainelli:
>> The Generic PHY drivers gets assigned after we checked that the current
>> PHY driver is NULL, so we need to check a few things before we can
>> safely dereference d->driver. This would be causing a NULL deference to
>> occur when a system binds to the Generic PHY driver. Update
>> phy_attach_direct() to do the following:
>>
>> - grab the driver module reference after we have assigned the Generic
>>    PHY drivers accordingly
>>
>> - update the error path to clean up the module reference in case the
>>    Generic PHY probe function fails
>>
>> Fixes: cafe8df8b9bc ("net: phy: Fix lack of reference count on PHY
>> driver")
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>   drivers/net/phy/phy_device.c | 16 +++++++++++++++-
>>   1 file changed, 15 insertions(+), 1 deletion(-)
> 
> just stumbled over this bug on an am335x based board, with an
> KSZ8081 attached, so there a "fixed-link" is used like:
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/arch/arm/boot/dts/am335x-baltos-ir3220.dts#n105
> 
> 
> With your patch it crashes also ...

The final version of the patch is here:

http://patchwork.ozlabs.org/patch/725923/

Do you mind giving it a try?
-- 
Florian
