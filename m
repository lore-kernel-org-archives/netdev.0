From: Adam Ford <aford173@gmail.com>
Subject: Re: Fwd: DA850-evm MAC Address is random
Date: Mon, 28 Aug 2017 15:32:40 -0500
Message-ID: <CAHCN7xLHEjda9DcVw5iHA9RaJ7UnyMVxf7e4e8NTEj9Op1JaBw@mail.gmail.com>
References: <CAHCN7xKwFd7dHF0ySEd1hOSr0sZEgh9fuwy=RkUTHvEh59hojQ@mail.gmail.com>
 <b7aab9fc-17ba-077b-3ff3-28087e0b25bc@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        Sekhar Nori <nsekhar@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f50.google.com ([209.85.213.50]:33567 "EHLO
        mail-vk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750735AbdH1Ucm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 16:32:42 -0400
In-Reply-To: <b7aab9fc-17ba-077b-3ff3-28087e0b25bc@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 28, 2017 at 1:54 PM, Grygorii Strashko
<grygorii.strashko@ti.com> wrote:
> Cc: Sekhar
>
> On 08/28/2017 10:32 AM, Adam Ford wrote:
>>
>> The davinvi_emac MAC address seems to attempt a call to
>> ti_cm_get_macid in cpsw-common.c but it returns the message
>> 'davinci_emac davinci_emac.1: incompatible machine/device type for
>> reading mac address ' and then generates a random MAC address.
>>
>> The function appears to lookup varions boards using
>> 'of_machine_is_compaible' and supports dm8148, am33xx, am3517, dm816,
>> am4372 and dra7.  I don't see the ti,davinci-dm6467-emac which is
>> what's shown in the da850 device tree.
>>
>> Is there a patch somewhere for supporting the da850-evm?
>
>
> Not sure if MAC address can be read from Control module.
> May be Sekhar can say more?

My understanding is that the MAC address is programmed by Logic PD
into the SPI flash.  The Bootloader reads this from either SPI or its
env variables.  Looking at the partition info listed in the
da850-evm.dts file, it appears as if they've reserved space for it.
Unfortunately, I don't see any code that reads it out.  I was hoping
there might be a way to just pass cmdline parameter from the
bootloader to the kernel to accept the MAC address.

>
>>
>> If not, is there a way to pass the MAC address from U-Boot to the
>> driver so it doesn't generate a random MAC?
>
>
> "local-mac-address" dt porp

The downside here, is that we'd have to have the Bootloader modify the
device tree.
>
> --
> regards,
> -grygorii

thanks

adam
