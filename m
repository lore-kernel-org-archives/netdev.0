From: Heiko Schocher <hs@denx.de>
Subject: Re: [net, v3, 1/3] net: phy: Fix PHY module checks and NULL deref in
 phy_attach_direct()
Date: Thu, 9 Feb 2017 08:29:37 +0100
Message-ID: <589C1A61.6040808@denx.de>
References: <20170209001401.2564-2-f.fainelli@gmail.com>
 <589C1309.5040302@denx.de> <8c63b88f-c7d3-dd53-e3a8-9d38bb5a154c@gmail.com>
Reply-To: hs@denx.de
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maowenan <maowenan@huawei.com>,
        andrew@lunn.ch, rmk+kernel@armlinux.org.uk, festevam@gmail.com,
        davem@davemloft.net, nikita.yoush@cogentembedded.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:51128 "EHLO
        mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751604AbdBIHaP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 02:30:15 -0500
In-Reply-To: <8c63b88f-c7d3-dd53-e3a8-9d38bb5a154c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Florian,

Am 09.02.2017 um 08:13 schrieb Florian Fainelli:
>
>
> On 02/08/2017 10:58 PM, Heiko Schocher wrote:
>> Hello Florian,
>>
>> Am 09.02.2017 um 01:13 schrieb Florian Fainelli:
>>> The Generic PHY drivers gets assigned after we checked that the current
>>> PHY driver is NULL, so we need to check a few things before we can
>>> safely dereference d->driver. This would be causing a NULL deference to
>>> occur when a system binds to the Generic PHY driver. Update
>>> phy_attach_direct() to do the following:
>>>
>>> - grab the driver module reference after we have assigned the Generic
>>>     PHY drivers accordingly
>>>
>>> - update the error path to clean up the module reference in case the
>>>     Generic PHY probe function fails
>>>
>>> Fixes: cafe8df8b9bc ("net: phy: Fix lack of reference count on PHY
>>> driver")
>>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>>> ---
>>>    drivers/net/phy/phy_device.c | 16 +++++++++++++++-
>>>    1 file changed, 15 insertions(+), 1 deletion(-)
>>
>> just stumbled over this bug on an am335x based board, with an
>> KSZ8081 attached, so there a "fixed-link" is used like:
>> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/arch/arm/boot/dts/am335x-baltos-ir3220.dts#n105
>>
>>
>> With your patch it crashes also ...
>
> The final version of the patch is here:
>
> http://patchwork.ozlabs.org/patch/725923/

Huh, sorry ...

> Do you mind giving it a try?

With this patch, ethernet works again fine on this board, thanks!

bye,
Heiko
-- 
DENX Software Engineering GmbH,      Managing Director: Wolfgang Denk
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
