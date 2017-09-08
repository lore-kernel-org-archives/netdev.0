From: Adam Ford <aford173@gmail.com>
Subject: Re: Fwd: DA850-evm MAC Address is random
Date: Fri, 8 Sep 2017 09:18:48 -0500
Message-ID: <CAHCN7xKUt_R7gVAfOnPBHUFLN6-_y7ShK-AUy1zJ0kCC3h+bdA@mail.gmail.com>
References: <CAHCN7xKwFd7dHF0ySEd1hOSr0sZEgh9fuwy=RkUTHvEh59hojQ@mail.gmail.com>
 <b7aab9fc-17ba-077b-3ff3-28087e0b25bc@ti.com> <CAHCN7xLHEjda9DcVw5iHA9RaJ7UnyMVxf7e4e8NTEj9Op1JaBw@mail.gmail.com>
 <20170828211217.GO6008@atomide.com> <94c4cbb0-1df3-2f2f-69f3-f9a788e610fa@ti.com>
 <CAHCN7x+-wymsqw96mt7Du=Huxh5rq=Rj9GidWPLXptJSW7taEA@mail.gmail.com>
 <f0f5e11f-cd7a-cb86-58b5-8ce44cdbc032@ti.com> <CAHCN7xK2=PN5MOr48HOkZnwKwkM4ypcvQct+Ko+ChNFG3Pv62w@mail.gmail.com>
 <955b0b1b-9bb7-ad25-4d6c-676be1efb943@ti.com> <CAHCN7x+paAdW7cXrALhtLZZiJbkE6v_8_qRXBec7hxLJPvSMbw@mail.gmail.com>
 <CAHCN7xKfZeyTHZShWGYYen50NSzTErh8X8np3WJfrYTBrO_RPw@mail.gmail.com>
 <ffec81da-78b6-7f1a-e477-ab0a9d2e4f37@ti.com> <1865772b-482e-042e-7c66-d33290f0d8fb@ti.com>
 <CAHCN7xLTfELMtcMLx=mKAsJrkuvH4Ubd-8rTGswUWC5nofU7mg@mail.gmail.com> <37fd2aaa-0802-9fde-61ee-43bdc287ff36@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tony Lindgren <tony@atomide.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org
To: Sekhar Nori <nsekhar@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f180.google.com ([209.85.217.180]:38850 "EHLO
        mail-ua0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752245AbdIHOSu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 10:18:50 -0400
In-Reply-To: <37fd2aaa-0802-9fde-61ee-43bdc287ff36@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 7, 2017 at 3:36 AM, Sekhar Nori <nsekhar@ti.com> wrote:
> On Thursday 07 September 2017 03:11 AM, Adam Ford wrote:
>> On Mon, Sep 4, 2017 at 11:42 PM, Sekhar Nori <nsekhar@ti.com> wrote:
>>> Hi Adam,
>>>
>>> On Wednesday 30 August 2017 11:08 AM, Sekhar Nori wrote:
>>>>> I wonder if U-Boot isn't pushing something to Linux because it doesn't
>>>>> appear to be running some of the da850 specific code even when I run
>>>>> linux-next.  Can you tell me what verision of U-Boot you're using?
>>>>> Other than using davinci_all_defconfig, did you change the
>>>>> configuration at all?
>>>
>>>> I am using U-Boot 2017.01. Yes, the kernel was built using
>>>> davinci_all_defconfig and no other config change. Before booting kernel,
>>>> can you confirm that ethaddr is set in U-Boot environment? This is what
>>>> fdt_fixup_ethernet() reads to fixup the FDT before boot.
>>>>
>>>> Here is my complete boot log with environment variable dump.
>>>>
>>>> http://pastebin.ubuntu.com/25430265/
>>>
>>> Were you able to get rid of the random mac address problem?
>>
>> Not yet.  I haven't been able to rebuild Arago using TI's instructions
>> on the Wiki.  I am not sure if it's a dependency issue or something
>> else.  When I run Linux 4.13 using Buildroot as the rootfs, it does
>> not appear to run da850_evm_m25p80_notify_add().  I am going to
>> investigate whether or not da850_evm_init() is getting called.  I was
>> wondering if you had some insight as to what calls that function?  It
>> looks like it's defined as part of MACHINE_START(DAVINCI_DA850_EVM,
>> "DaVinci DA850/OMAP-L138/AM18x EVM"), but I don't know how it gets
>> called.
>
> These functions are called only when booting using the legacy board file
> method. From your logs before, you are booting using device tree. So
> these functions are irrelevant.

Ok. That makes a lot more sense now.  I was really confused why the functions
were not getting called.

> Can you check if the mac address has been populated in the device-tree
> by dumping it from /proc/device-tree/.../local-mac-address? That will
> tell us if U-Boot is updating the mac address or not.

It does not appear to getting called.

# hexdump ./soc@1c00000/ethernet@220000/local-mac-address
0000000 0000 0000 0000
0000006
#

I'll work on something that pulls in the MAC address then inserts it
into the device tree like the recommendation that Tony made.

Thanks for all your help.

adam
>
> Thanks,
> Sekhar
