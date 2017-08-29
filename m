From: Adam Ford <aford173@gmail.com>
Subject: Re: Fwd: DA850-evm MAC Address is random
Date: Tue, 29 Aug 2017 05:23:30 -0500
Message-ID: <CAHCN7x+-wymsqw96mt7Du=Huxh5rq=Rj9GidWPLXptJSW7taEA@mail.gmail.com>
References: <CAHCN7xKwFd7dHF0ySEd1hOSr0sZEgh9fuwy=RkUTHvEh59hojQ@mail.gmail.com>
 <b7aab9fc-17ba-077b-3ff3-28087e0b25bc@ti.com> <CAHCN7xLHEjda9DcVw5iHA9RaJ7UnyMVxf7e4e8NTEj9Op1JaBw@mail.gmail.com>
 <20170828211217.GO6008@atomide.com> <94c4cbb0-1df3-2f2f-69f3-f9a788e610fa@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tony Lindgren <tony@atomide.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org
To: Sekhar Nori <nsekhar@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f49.google.com ([209.85.213.49]:37191 "EHLO
        mail-vk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751238AbdH2KXb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 06:23:31 -0400
In-Reply-To: <94c4cbb0-1df3-2f2f-69f3-f9a788e610fa@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 29, 2017 at 3:23 AM, Sekhar Nori <nsekhar@ti.com> wrote:
> On Tuesday 29 August 2017 02:42 AM, Tony Lindgren wrote:
>> * Adam Ford <aford173@gmail.com> [170828 13:33]:
>>> On Mon, Aug 28, 2017 at 1:54 PM, Grygorii Strashko
>>> <grygorii.strashko@ti.com> wrote:
>>>> Cc: Sekhar
>>>>
>>>> On 08/28/2017 10:32 AM, Adam Ford wrote:
>>>>>
>>>>> The davinvi_emac MAC address seems to attempt a call to
>>>>> ti_cm_get_macid in cpsw-common.c but it returns the message
>>>>> 'davinci_emac davinci_emac.1: incompatible machine/device type for
>>>>> reading mac address ' and then generates a random MAC address.
>>>>>
>>>>> The function appears to lookup varions boards using
>>>>> 'of_machine_is_compaible' and supports dm8148, am33xx, am3517, dm816,
>>>>> am4372 and dra7.  I don't see the ti,davinci-dm6467-emac which is
>>>>> what's shown in the da850 device tree.
>>>>>
>>>>> Is there a patch somewhere for supporting the da850-evm?
>>>>
>>>>
>>>> Not sure if MAC address can be read from Control module.
>>>> May be Sekhar can say more?
>>>
>>> My understanding is that the MAC address is programmed by Logic PD
>>> into the SPI flash.  The Bootloader reads this from either SPI or its
>>> env variables.  Looking at the partition info listed in the
>>> da850-evm.dts file, it appears as if they've reserved space for it.
>>> Unfortunately, I don't see any code that reads it out.  I was hoping
>
> This code is present in U-Boot sources at
> board/davinci/da8xxevm/da850evm.c. See the function get_mac_addr() and
> its usage in misc_init_r().
>
>>> there might be a way to just pass cmdline parameter from the
>>> bootloader to the kernel to accept the MAC address.
>>>
>>>>
>>>>>
>>>>> If not, is there a way to pass the MAC address from U-Boot to the
>>>>> driver so it doesn't generate a random MAC?
>>>>
>>>>
>>>> "local-mac-address" dt porp
>>>
>>> The downside here, is that we'd have to have the Bootloader modify the
>>> device tree.
>>
>> That piece of code exists somewhere in u-boot already. Note how
>
> Yes, it is fdt_fixup_ethernet() and its usage is in common/image-fdt.c.
>
>> we are populating the mac address for USB Ethernet drivers in
>> u-boot and then the Ethernet driver code parses it. See commit
>> 055d31de7158 ("ARM: omap3: beagleboard-xm: dt: Add ethernet to
>> the device tree") for some more information.
>>
>> I think u-boot needs the ethernet alias for finding the interface.
>
> That's exactly what was missing. I have sent a patch for fixing that and
> copied you there.

Thanks for doing that.

>
> Adam, if I can get your Tested-by, I will make an attempt to send it for
> v4.13 itself.

I will test it.  Do need to run some instruction or do something
special in U-Boot to pass this in the proper place for the kernel to
pull it?  Tony's patch reference showed
command for fdt set, but I am not sure I fully understand the
parameters that went along with that.

adam
>
> Thanks,
> Sekhar
